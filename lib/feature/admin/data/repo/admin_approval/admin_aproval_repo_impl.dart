import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/admin/data/repo/admin_approval/admin_approval_repo.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';
import 'package:optialeader/feature/doctor/data/repo/activities/activity_repo.dart';
import 'package:optialeader/feature/doctor/data/repo/research_paper/research_paper_repo.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';

class AdminApprovalRepoImpl extends AdminApprovalRepo { 
  final FirebaseFirestore firebaseFirestore;
  final ResearchPaperRepo researchPaperRepo;
  final ActivityRepo activityRepo;
  final NotificationRepo notificationRepo;

  AdminApprovalRepoImpl({ 
    required this.firebaseFirestore,
    required this.researchPaperRepo,
    required this.activityRepo,
    required this.notificationRepo,
  });

  CollectionReference get _usersCollection =>
      firebaseFirestore.collection('users');

  @override
  Future<Either<String, List<DoctorProfileModel>>> getPendingRequests() async {
    try {
      final snapshot = await _usersCollection.where('role', isEqualTo: 'doctor').get();
      
      final doctors = snapshot.docs.map((doc) {
        return DoctorProfileModel.fromJson(
          doc.data() as Map<String, dynamic>, 
          doc.id,
        );
      }).toList();

      final pendingDoctors = doctors.where((doc) => 
          doc.researchPapers.any((p) => p.status == VerificationStatus.pending) || 
          doc.activities.any((a) => a.status == VerificationStatus.pending) ||
          doc.trainingCourses.any((c) => c.status == VerificationStatus.pending)
      ).toList();

      return right(pendingDoctors);
    } catch (e) {
      return left("فشل جلب الطلبات المعلقة: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, Unit>> approveResearch(String doctorUid, String paperId, String paperTitle) async {
    final result = await researchPaperRepo.updatePaperStatus(
      doctorUid, paperId, VerificationStatus.approved,
    );
    
    return result.fold(
      (error) => left(error),
      (_) {
        _sendStatusNotification(
          doctorUid: doctorUid,
          title: paperTitle,
          message: 'تمت الموافقة على بحثك',
          type: NotificationType.researchStatusUpdated,
          relatedId: paperId,
        );
        return right(unit);
      },
    );
  }

  @override
  Future<Either<String, Unit>> rejectResearch(String doctorUid, String paperId, String paperTitle, String reason) async {
    final result = await researchPaperRepo.updatePaperStatus(
      doctorUid, paperId, VerificationStatus.rejected,
      rejectionReason: reason,
    );
    
    return result.fold(
      (error) => left(error),
      (_) {
        _sendStatusNotification(
          doctorUid: doctorUid,
          title: paperTitle,
          message: 'تم رفض بحثك، السبب: $reason',
          type: NotificationType.researchStatusUpdated,
          relatedId: paperId,
        );
        return right(unit);
      },
    );
  }

  @override
  Future<Either<String, Unit>> approveActivity(String doctorUid, String activityId, String activityTitle) async {
    final result = await activityRepo.updateActivityStatus(
      doctorUid, activityId, VerificationStatus.approved,
    );
    
    return result.fold(
      (error) => left(error),
      (_) {
        _sendStatusNotification(
          doctorUid: doctorUid,
          title: activityTitle,
          message: 'تمت الموافقة على نشاطك',
          type: NotificationType.activityStatusUpdated,
          relatedId: activityId,
        );
        return right(unit);
      },
    );
  }

  @override
  Future<Either<String, Unit>> rejectActivity(String doctorUid, String activityId, String activityTitle, String reason) async {
    final result = await activityRepo.updateActivityStatus(
      doctorUid, activityId, VerificationStatus.rejected,
      rejectionReason: reason,
    );
    
    return result.fold(
      (error) => left(error),
      (_) {
        _sendStatusNotification(
          doctorUid: doctorUid,
          title: activityTitle,
          message: 'تم رفض نشاطك، السبب: $reason',
          type: NotificationType.activityStatusUpdated,
          relatedId: activityId,
        );
        return right(unit);
      },
    );
  }

  void _sendStatusNotification({
    required String doctorUid,
    required String title,
    required String message,
    required NotificationType type,
    required String relatedId,
  }) {
    notificationRepo.sendNotification(
      AppNotificationModel(
        id: '',
        title: 'تحديث حالة الطلب',
        message: '$message: $title',
        type: type,
        timestamp: Timestamp.now(),
        relatedId: relatedId,
        receiverId: doctorUid,
      ),
    );
  }
}