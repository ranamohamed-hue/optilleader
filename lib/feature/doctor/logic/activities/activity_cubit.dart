import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:optialeader/feature/doctor/data/model/activities_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';
import 'package:optialeader/feature/doctor/data/repo/activities/activity_repo.dart';
import 'package:optialeader/feature/doctor/logic/activities/acativity_state.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart'; 
import 'package:optialeader/feature/notification/data/repo/notification_repo_impl.dart'; 

class ActivityCubit extends Cubit<ActivityState> {
  final ActivityRepo activityRepo;
  final NotificationRepoImpl notificationRepo; 

  ActivityCubit(this.activityRepo, this.notificationRepo) : super(ActivityInitial()); 

  Future<void> addNewActivity({
    required String doctorUid,
    required ActivityModel activity,
    File? proofFile,
  }) async {
    emit(ActivityLoading());
    final result = await activityRepo.addActivity(
      doctorUid: doctorUid,
      activity: activity,
      proofFile: proofFile,
    );
    result.fold(
      (error) => emit(ActivityError(error: error)),
      (_) async {
        emit(ActivitySuccess());
        
        try {
          final adminsSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'admin')
              .get();
          
          final List<String> adminIds = adminsSnapshot.docs.map((doc) => doc.id).toList();

          if (adminIds.isNotEmpty) {
            // 2. نبني الإشعار
            final notification = AppNotificationModel(
              id: '', // الفايرستور هيولده تلقائي
              title: 'طلب اعتماد نشاط جديد',
              message: 'تم إضافة نشاط بعنوان: ${activity.title} يحتاج موافقتك',
              type: NotificationType.newActivitySubmitted,
              timestamp: Timestamp.now(),
              receiverId: '', // هيتتجاوز لأننا بنستخدم broadcast
              relatedId: activity.id, // ✅ مهم جداً عشان الأدمن يفتح النشاط الصح
              doctorUid: doctorUid, // ✅ مهم جداً عشان الأدمن يفتح بيانات الدكتور الصح
            );
            
            // 3. نبعت الإشعار الجماعي للأدمنز
            await notificationRepo.broadcastNotification(adminIds, notification);
          }
        } catch (e) {
          print("فشل إرسال إشعار للأدمن: $e");
          // مبنعملش emit Error عشان العملية الأساسية (إضافة النشاط) نجحت بالفعل
        }
      },
    );
  }

  // ... باقي الدوال (deleteActivity, updateActivityStatus, approveActivity, rejectActivity) زي ما هي ...
}