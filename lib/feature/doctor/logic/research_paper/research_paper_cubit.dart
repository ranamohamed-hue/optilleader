import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:optialeader/feature/doctor/data/model/research_paper_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';
import 'package:optialeader/feature/doctor/data/repo/research_paper/research_paper_repo.dart';
import 'package:optialeader/feature/doctor/logic/research_paper/research_paper_state.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';

class ResearchCubit extends Cubit<ResearchState> {
  final ResearchPaperRepo researchRepo;
  final NotificationRepo notificationRepo; // محتاجينه عشان addNewResearch بس

  ResearchCubit(this.researchRepo, this.notificationRepo)
      : super(ResearchInitial());

  Future<void> addNewResearch({
    required String doctorUid,
    required ResearchPaperModel paper,
    required File paperFile,
    File? indexingProofFile,
  }) async {
    emit(ResearchLoading());
    final result = await researchRepo.addResearchPaper(
      doctorUid: doctorUid,
      paper: paper,
      paperFile: paperFile,
      indexingProofFile: indexingProofFile,
    );
    
    result.fold(
      (error) => emit(ResearchError(error: error)),
      (_) async {
        emit(ResearchSuccess());
        
        // ✅ إرسال إشعار للأدمن إن في بحث جديد (ده موجود صح)
        try {
          final notification = AppNotificationModel(
            id: '',
            title: 'طلب اعتماد بحث جديد',
            message: 'تم إضافة بحث بعنوان: "${paper.titleAr}" يحتاج موافقتك',
            type: NotificationType.newResearchSubmitted,
            target: NotificationTarget.adminOnly, // ✅ محدد إنه للأدمن بس
            timestamp: Timestamp.now(),
            receiverId: '', 
            relatedId: paper.id,
            doctorUid: doctorUid,
          );

          await notificationRepo.sendRoleBasedNotification(notification);
          print("✅ Notifications sent to admins successfully via Role-Based logic");
        } catch (e) {
          print("🚨 Error sending admin notification: $e");
        }
      },
    );
  }

  Future<void> deleteResearch(String doctorUid, String paperId) async {
    emit(ResearchLoading());
    final result = await researchRepo.deleteResearchPaper(doctorUid, paperId);
    result.fold(
      (error) => emit(ResearchError(error: error)),
      (_) => emit(ResearchSuccess()),
    );
  }

  // ✅ تم مسح الإشعار من هنا عشان الـ AdminApprovalRepoImpl هو اللي يبعته
  Future<void> approveResearch(String doctorUid, String paperId) async {
    emit(ResearchLoading());
    final result = await researchRepo.updatePaperStatus(
      doctorUid,
      paperId,
      VerificationStatus.approved,
    );
    
    result.fold(
      (error) => emit(ResearchError(error: error)),
      (_) => emit(ResearchSuccess()), // خلاص، أتحتت الحالة والإشعار راح من الـ Repo
    );
  }

  // ✅ تم مسح الإشعار من هنا برضو
  Future<void> rejectResearch(
    String doctorUid,
    String paperId,
    String reason,
  ) async {
    emit(ResearchLoading());
    final result = await researchRepo.updatePaperStatus(
      doctorUid,
      paperId,
      VerificationStatus.rejected,
      rejectionReason: reason,
    );
    
    result.fold(
      (error) => emit(ResearchError(error: error)),
      (_) => emit(ResearchSuccess()), // خلاص، أتحتت الحالة والإشعار راح من الـ Repo
    );
  }
}