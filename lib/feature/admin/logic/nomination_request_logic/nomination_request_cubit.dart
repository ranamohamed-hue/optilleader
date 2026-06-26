import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/admin/data/model/nomination_request_model.dart';
import 'package:optialeader/feature/admin/data/model/nomination_score_model.dart';
import 'package:optialeader/feature/admin/data/repo/nomination_request/nomination_request_repo.dart';
import 'package:optialeader/feature/admin/logic/nomination_request_logic/nomonation_request_state.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/leadership_scoring_engine/leadership_scoring_engine.dart';
import 'package:optialeader/feature/judge/data/model/interview_scoring_model.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';
import 'package:intl/intl.dart';
class NominationRequestCubit extends Cubit<NominationRequestState> {
  final NominationRequestRepository _repository;
  final NotificationRepo _notificationRepo;

  NominationRequestCubit(this._repository, this._notificationRepo)
      : super(NominationRequestInitial());

  void fetchAdminRequests({required String status}) {
    emit(NominationRequestLoading());
    _repository.getAdminRequests(status: status).listen(
          (requests) => emit(NominationRequestLoaded(requests)),
          onError: (e) => emit(NominationRequestError("error_fetch_requests")),
        );
  }

  void fetchEvaluatorRequests(String evaluatorId) {
    emit(NominationRequestLoading());
    _repository.getEvaluatorRequests(evaluatorId).listen(
          (requests) => emit(NominationRequestLoaded(requests)),
          onError: (e) =>
              emit(NominationRequestError("error_fetch_evaluator_requests")),
        );
  }

  Future<void> submitNominationRequest({
    required AnnouncementModel announcement,
    required DoctorProfileModel doctor,
    String? filePath,
  }) async {
    final doctorId = doctor.uid;
    final doctorName = doctor.nameAr;
    final doctorImageUrl = doctor.profileImage;

    if (doctorId == null || doctorId.isEmpty) {
      emit(NominationRequestError("error_invalid_doctor"));
      return;
    }

    final existingRequestSnapshot = await FirebaseFirestore.instance
        .collection('nomination_requests')
        .where('doctorId', isEqualTo: doctorId)
        .where('announcementId', isEqualTo: announcement.id!)
        .where('status', whereIn: [
          NominationRequestModel.statusPendingAdmin,
          NominationRequestModel.statusPendingEvaluator
        ])
        .limit(1)
        .get();

    if (existingRequestSnapshot.docs.isNotEmpty) {
      emit(NominationRequestError("nomination.error_duplicate_request"));
      return;
    }

    emit(NominationRequestLoading());
    try {
      String? fileUrl;
      if (filePath != null) {
        final uploadResult = await _repository.uploadDeclarationFile(filePath);
        if (uploadResult.isLeft()) {
          emit(NominationRequestError("error_upload_declaration"));
          return;
        }
        fileUrl = uploadResult.getOrElse(() => '');
      }

      // ✅ بناء موديل الدرجات الجديد
      final NominationScoreModel scores = LeadershipScoringEngine.buildScoreModel(doctor);

            final request = NominationRequestModel(
        doctorId: doctorId,
        doctorName: doctorName,
        doctorImageUrl: doctorImageUrl.isEmpty ? null : doctorImageUrl,
        announcementId: announcement.id!,
        targetRole: announcement.targetRole,
        collegeId: announcement.collegeId,
        collegeName: doctor.facultyAr, // ✅ أضف هذا السطر
        departmentId: announcement.departmentId,
        departmentName: doctor.departmentAr, // ✅ أضف هذا السطر
        scores: scores, 
        declarationFileUrl: fileUrl,
        status: NominationRequestModel.statusPendingAdmin,
        createdAt: DateTime.now(),
      );

      final result = await _repository.submitRequest(request);
      result.fold(
        (error) => emit(NominationRequestError("error_submit_request")),
        (generatedId) {
          emit(NominationRequestActionSuccess("success_submit_request"));
          _sendNewRequestNotification(
            request.copyWith(id: generatedId),
            announcement.title,
          );
        },
      );
    } catch (e) {
      emit(NominationRequestError("error_unexpected"));
    }
  }

  Future<void> adminTakeAction({
    required NominationRequestModel request,
    required String newStatus,
    String? rejectionReason,
    String? evaluatorId,
    String? evaluatorName,
  }) async {
    final updatedRequest = request.copyWith(
      status: newStatus,
      rejectionReason: rejectionReason,
      evaluatorId: evaluatorId,
      evaluatorName: evaluatorName,
      updatedAt: DateTime.now(),
    );

    final result = await _repository.updateRequest(updatedRequest);
    result.fold(
      (error) => emit(NominationRequestError("error_update_request")),
      (_) {
        emit(NominationRequestActionSuccess("success_action_taken"));

        if (newStatus == NominationRequestModel.statusPendingEvaluator) {
          _sendToEvaluatorNotification(updatedRequest);
        } else if (newStatus == NominationRequestModel.statusRejectedByAdmin) {
          _sendStatusUpdateToDoctor(updatedRequest, isAccepted: false);
        } else if (newStatus == NominationRequestModel.statusFinalApprovedPendingAnnouncement) {
          _sendEvaluationDoneToAdmin(updatedRequest);
        } else if (newStatus == NominationRequestModel.statusFinalApproved) {
          _sendStatusUpdateToDoctor(updatedRequest, isAccepted: true);
        } else if (newStatus == NominationRequestModel.statusFinalRejected) {
          _sendStatusUpdateToDoctor(updatedRequest, isAccepted: false);
        }
      },
    );
  }

  // ✅ دالة تحديد موعد المقابلة
  Future<void> scheduleInterview({
    required NominationRequestModel request,
    required DateTime interviewDate,
    required String location,
    required String time,
  }) async {
    emit(NominationRequestLoading());

    final updatedRequest = request.copyWith(
      interviewDate: interviewDate,
      interviewLocation: location,
      interviewTime: time,
      updatedAt: DateTime.now(),
    );

    final result = await _repository.updateRequest(updatedRequest);
    result.fold(
      (error) => emit(NominationRequestError("error_schedule_interview")),
      (_) {
        emit(NominationRequestActionSuccess("success_interview_scheduled"));
        _sendInterviewScheduledNotification(updatedRequest);
      },
    );
  }
   // ✅ دالة جلب المحكمين بنمط الـ BLoC الصحيح
  void fetchEvaluators() async {
    emit(EvaluatorsLoading());
    final result = await _repository.getEvaluators();
    result.fold(
      (failure) => emit(EvaluatorsError(failure)),
      (evaluators) => emit(EvaluatorsLoaded(evaluators)),
    );
  }
  // ✅ الدالة الموحدة لتقييم المقابلة
  Future<void> submitInterviewEvaluation({
    required String requestId,
    required NominationRequestModel request,
    required InterviewScoringModel evaluationModel,
  }) async {
    emit(NominationRequestLoading());

    try {
      final newStatus = evaluationModel.isDraft
          ? NominationRequestModel.statusPendingEvaluator
          : NominationRequestModel.statusEvaluated;

      // ✅ تحديث موديل الدرجات بإضافة درجات المقابلة
      final updatedScores = LeadershipScoringEngine.addInterviewScore(
        request.scores ?? NominationScoreModel(),
        evaluationModel,
      );

      final updatedRequest = request.copyWith(
        status: newStatus,
        scores: updatedScores, // ✅ حفظ الدرجات المحدثة
        interviewDate: evaluationModel.interviewDate,
        evaluatorPoints: evaluationModel.totalScore,
        evaluatorNotes: evaluationModel.combinedNotes,
        interviewEvaluation: evaluationModel.toMap(),
        updatedAt: DateTime.now(),
      );

      final result = await _repository.updateRequest(updatedRequest);

      result.fold(
        (error) => emit(NominationRequestError('error_evaluation_submit')),
        (_) {
          emit(NominationRequestActionSuccess('success_evaluation_submitted'.tr()));
          if (!evaluationModel.isDraft) {
            _sendEvaluationDoneToAdmin(updatedRequest);
          }
        },
      );
    } catch (e) {
      emit(NominationRequestError(e.toString()));
    }
  }

  // ====== الإشعارات ======

  Future<void> _sendNewRequestNotification(
    NominationRequestModel request,
    String announcementTitle,
  ) async {
    try {
      final notification = AppNotificationModel(
        id: '',
        title: 'طلب ترشح جديد',
        message: 'قدم د/ ${request.doctorName} على مسابقة "$announcementTitle"',
        type: NotificationType.newDoctorRequest,
        target: NotificationTarget.adminOnly,
        timestamp: Timestamp.now(),
        receiverId: '',
        relatedId: request.id,
      );
      await _notificationRepo.sendRoleBasedNotification(notification);
    } catch (e) {
      print("فشل إرسال إشعار للإدمن: $e");
    }
  }

  Future<void> _sendToEvaluatorNotification(
    NominationRequestModel request,
  ) async {
    try {
      final notification = AppNotificationModel(
        id: '',
        title: 'طلب تقييم جديد',
        message: 'تم تحويل طلب د/ ${request.doctorName} إليك للتقييم',
        type: NotificationType.newArbitrationRequest,
        target: NotificationTarget.specificUser,
        timestamp: Timestamp.now(),
        receiverId: request.evaluatorId!,
        relatedId: request.id,
      );
      await _notificationRepo.sendNotification(notification);
    } catch (e) {
      print("فشل إرسال إشعار للمحكم: $e");
    }
  }

  Future<void> _sendStatusUpdateToDoctor(
    NominationRequestModel request, {
    required bool isAccepted,
  }) async {
    try {
      final notification = AppNotificationModel(
        id: '',
        title: isAccepted ? 'قبول الطلب' : 'رفض الطلب',
        message: isAccepted
            ? 'تمت الموافقة النهائية على طلب ترشحك'
            : 'تم رفض طلب ترشحك. السبب: ${request.rejectionReason ?? "غير محدد"}',
        type: NotificationType.requestStatusUpdate,
        target: NotificationTarget.specificUser,
        timestamp: Timestamp.now(),
        receiverId: request.doctorId,
        relatedId: request.id,
      );
      await _notificationRepo.sendNotification(notification);
    } catch (e) {
      print("فشل إرسال إشعار للدكتور: $e");
    }
  }

  Future<void> _sendEvaluationDoneToAdmin(
    NominationRequestModel request,
  ) async {
    try {
      final notification = AppNotificationModel(
        id: '',
        title: 'تم إنهاء التقييم',
        message: 'قام المحكم بتقييم طلب د/ ${request.doctorName} وإعادته لك',
        type: NotificationType.judgeRequestCompleted,
        target: NotificationTarget.adminOnly,
        timestamp: Timestamp.now(),
        receiverId: '',
        relatedId: request.id,
      );
      await _notificationRepo.sendRoleBasedNotification(notification);
    } catch (e) {
      print("فشل إرسال إشعار للإدمن: $e");
    }
  }

  // ✅ إشعار تحديد موعد المقابلة
  Future<void> _sendInterviewScheduledNotification(
    NominationRequestModel request,
  ) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(request.interviewDate!);
      final notification = AppNotificationModel(
        id: '',
        title: 'تحديد موعد مقابلة',
        message:
            'تم تحديد مقابلتك بتاريخ $dateStr الساعة ${request.interviewTime} بمكان: ${request.interviewLocation}',
        type: NotificationType.requestStatusUpdate,
        target: NotificationTarget.specificUser,
        timestamp: Timestamp.now(),
        receiverId: request.doctorId,
        relatedId: request.id,
      );
      await _notificationRepo.sendNotification(notification);
    } catch (e) {
      print("فشل إرسال إشعار الموعد: $e");
    }
  }
}