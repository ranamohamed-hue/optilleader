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
    // 1. جلب كل المستخدمين من كولكشن 'users'
    final snapshot = await firebaseFirestore.collection('users').get();
    
    print("--- بدأ الفحص ---");
    print("عدد المستخدمين الذين تم العثور عليهم: ${snapshot.docs.length}");

    final List<DoctorProfileModel> pendingDoctors = [];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      
      // 2. نقوم بطباعة بيانات كل مستخدم لنرى شكل الحقول لديه
      // هذا السطر سيكشف لنا لماذا 'profile.role' لا تعمل
      print("مستخدم ID: ${doc.id} | البيانات: $data");

      // 3. محاولة مطابقة البيانات (عدلي هذا الشرط بناءً على ما سيظهر في الـ Console)
      // إذا كان الـ role موجوداً مباشرة:
      final role = data['role'] ?? (data['profile'] != null ? data['profile']['role'] : '');
      
      if (role == 'doctor') {
        final doctor = DoctorProfileModel.fromJson(data, doc.id);
        
        // التحقق من وجود أبحاث أو أنشطة معلقة
        bool hasPending = doctor.researchPapers.any((p) => p.status == VerificationStatus.pending) || 
                          doctor.activities.any((a) => a.status == VerificationStatus.pending) ||
                          doctor.trainingCourses.any((c) => c.status == VerificationStatus.pending);
        
        if (hasPending) {
          pendingDoctors.add(doctor);
        }
      }
    }

    print("عدد الدكاترة الذين لديهم طلبات معلقة: ${pendingDoctors.length}");
    print("--- انتهى الفحص ---");
    
    return right(pendingDoctors);
  } catch (e) {
    print("خطأ فادح أثناء الجلب: $e");
    return left("فشل جلب الطلبات: ${e.toString()}");
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