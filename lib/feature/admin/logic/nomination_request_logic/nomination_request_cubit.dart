import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/admin/data/model/nomination_request_model.dart';
import 'package:optialeader/feature/admin/data/repo/nomination_request/nomination_request_repo.dart';
import 'package:optialeader/feature/admin/logic/nomination_request_logic/nomonation_request_state.dart';
import 'package:optialeader/feature/judge/data/model/interview_scoring_model.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';
import 'package:easy_localization/easy_localization.dart';
class NominationRequestCubit extends Cubit<NominationRequestState> {
  final NominationRequestRepository _repository;
  final NotificationRepo _notificationRepo;

  NominationRequestCubit(this._repository, this._notificationRepo)
    : super(NominationRequestInitial());

  void fetchAdminRequests({required String status}) {
    emit(NominationRequestLoading());
    _repository
        .getAdminRequests(status: status)
        .listen(
          (requests) => emit(NominationRequestLoaded(requests)),
          onError: (e) => emit(NominationRequestError("error_fetch_requests")),
        );
  }

  void fetchEvaluatorRequests(String evaluatorId) {
    emit(NominationRequestLoading());
    _repository
        .getEvaluatorRequests(evaluatorId)
        .listen(
          (requests) => emit(NominationRequestLoaded(requests)),
          onError: (e) =>
              emit(NominationRequestError("error_fetch_evaluator_requests")),
        );
  }

    Future<void> submitNominationRequest({
    required AnnouncementModel announcement,
    required String doctorId,
    required String doctorName,
    String? doctorImageUrl,
    required double systemTotalPoints,
    required Map<String, dynamic> systemPointsBreakdown,
    required String? filePath,
  }) async {
    // ✅ 1. التحقق من وجود طلب سابق (منع التكرار)
    // بنبحث لو فيه طلب لنفس الدكتور ونفس الإعلان وحالته "تحت النظر"
    final existingRequestSnapshot = await FirebaseFirestore.instance
        .collection('nomination_requests')
        .where('doctorId', isEqualTo: doctorId)
        .where('announcementId', isEqualTo: announcement.id!)
        .where('status', whereIn: [
            NominationRequestModel.statusPendingAdmin,
            NominationRequestModel.statusPendingEvaluator
          ])
        .limit(1) // بنحتاج نعرف بس في موجود ولا لأ، زي ما ناخد أول واحد
        .get();

    // لو لقينا طلب، نوقف العملية ونرجع خطأ
    if (existingRequestSnapshot.docs.isNotEmpty) {
      emit(NominationRequestError("nomination.error_duplicate_request"));
      return;
    }

    // ✅ 2. لو مفيش تكرار، نكمل البرنامج العادي
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

      final request = NominationRequestModel(
        doctorId: doctorId,
        doctorName: doctorName,
        doctorImageUrl: doctorImageUrl,
        announcementId: announcement.id!,
        targetRole: announcement.targetRole,
        collegeId: announcement.collegeId,
        departmentId: announcement.departmentId,
        systemTotalPoints: systemTotalPoints,
        systemPointsBreakdown: systemPointsBreakdown,
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
    result.fold((error) => emit(NominationRequestError("error_update_request")), (
      _,
    ) {
      emit(NominationRequestActionSuccess("success_action_taken"));

      if (newStatus == NominationRequestModel.statusPendingEvaluator) {
        _sendToEvaluatorNotification(updatedRequest);
      } else if (newStatus == NominationRequestModel.statusRejectedByAdmin ||
          newStatus == NominationRequestModel.statusFinalRejected) {
        _sendStatusUpdateToDoctor(updatedRequest, isAccepted: false);
      }
      // ✅ التعديل هنا: الموافقة النهائية بتخلي الحالة "بانتظار الإعلان" ومبتبعتش إشعار قبول للأستاذ لحد ما الإعلان ينزل
      else if (newStatus ==
          NominationRequestModel.statusFinalApprovedPendingAnnouncement) {
        _sendEvaluationDoneToAdmin(
          updatedRequest,
        ); // مجرد إشعار للإدمن إن الإجراء تم
      }
    });
  }

  Future<void> evaluatorSubmitEvaluation({
    required NominationRequestModel request,
    required DateTime interviewDate,
    required double evaluatorPoints,
    required String evaluatorNotes,
  }) async {
    final updatedRequest = request.copyWith(
      status: NominationRequestModel.statusEvaluated,
      interviewDate: interviewDate,
      evaluatorPoints: evaluatorPoints,
      evaluatorNotes: evaluatorNotes,
      updatedAt: DateTime.now(),
    );

    final result = await _repository.updateRequest(updatedRequest);
    result.fold(
      (error) => emit(NominationRequestError("error_evaluation_submit")),
      (_) {
        emit(NominationRequestActionSuccess("success_evaluation_submitted"));
        _sendEvaluationDoneToAdmin(updatedRequest);
        _sendInterviewDateToDoctor(updatedRequest);
      },
    );
  }

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
      print("🚨 فشل إرسال إشعار للإدمن: $e");
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
      print("🚨 فشل إرسال إشعار للمحكم: $e");
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
      print("🚨 فشل إرسال إشعار للدكتور: $e");
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
      print("🚨 فشل إرسال إشعار للإدمن: $e");
    }
  }

  Future<void> _sendInterviewDateToDoctor(
    NominationRequestModel request,
  ) async {
    try {
      // ✅ التعديل هنا: شيلنا التاريخ العربي المحدد وسيبناه للـ UI يترجمه
      final notification = AppNotificationModel(
        id: '',
        title: 'تحديد موعد مقابلة',
        message: 'تم تحديد موعد مقابلتك، يرجى المتابعة.',
        type: NotificationType.requestStatusUpdate,
        target: NotificationTarget.specificUser,
        timestamp: Timestamp.now(),
        receiverId: request.doctorId,
        relatedId: request.id,
      );
      await _notificationRepo.sendNotification(notification);
    } catch (e) {
      print("🚨 فشل إرسال ميعاد المقابلة للدكتور: $e");
    }
  }
    // دالة حفظ تقييم المقابلة
  Future<void> submitInterviewEvaluation({
    required String requestId,
    required InterviewScoringModel evaluationModel,
  }) async {
    emit(NominationRequestLoading());

    try {
      final newStatus = evaluationModel.isDraft 
          ? 'draft'
          : 'evaluated';

      await FirebaseFirestore.instance
          .collection('nomination_requests')
          .doc(requestId)
          .update({
        'interviewEvaluation': evaluationModel.toMap(),
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // ✅ التصحيح: استخدام المفتاح الموجود في JSON بتاعك
      emit(NominationRequestActionSuccess('success_evaluation_submitted'.tr()));
      
    } catch (e) {
      emit(NominationRequestError(e.toString()));
    }
  }
}
