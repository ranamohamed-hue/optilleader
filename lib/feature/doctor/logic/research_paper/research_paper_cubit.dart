import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ [إضافة]
import 'package:optialeader/feature/doctor/data/model/research_paper_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';
import 'package:optialeader/feature/doctor/data/repo/research_paper/research_paper_repo.dart';
import 'package:optialeader/feature/doctor/logic/research_paper/research_paper_state.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart'; // ✅ [إضافة]
import 'package:optialeader/feature/notification/data/repo/notification_repo_impl.dart'; // ✅ [إضافة]

class ResearchCubit extends Cubit<ResearchState> {
  final ResearchPaperRepo researchRepo;
  final NotificationRepoImpl notificationRepo; // ✅ [إضافة]

  ResearchCubit(this.researchRepo, this.notificationRepo) : super(ResearchInitial()); // ✅ [تعديل]

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
        
        // ✅✅✅ [إضافة] إرسال إشعار للأدمنز بعد نجاح الإضافة
        try {
          final adminsSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'admin')
              .get();
          
          final List<String> adminIds = adminsSnapshot.docs.map((doc) => doc.id).toList();

          if (adminIds.isNotEmpty) {
            final notification = AppNotificationModel(
              id: '',
              title: 'طلب اعتماد بحث جديد',
              message: 'تم إضافة بحث بعنوان: ${paper.titleAr} يحتاج موافقتك',
              type: NotificationType.newResearchSubmitted,
              timestamp: Timestamp.now(),
              receiverId: '',
              relatedId: paper.id, // ✅ مهم جداً
              doctorUid: doctorUid, // ✅ مهم جداً
            );
            
            await notificationRepo.broadcastNotification(adminIds, notification);
          }
        } catch (e) {
          print("فشل إرسال إشعار للأدمن: $e");
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

  Future<void> updatePaperStatus(
    String doctorUid,
    String paperId,
    VerificationStatus status, {
    String? rejectionReason,
  }) async {
    emit(ResearchLoading());
    final result = await researchRepo.updatePaperStatus(
      doctorUid,
      paperId,
      status,
      rejectionReason: rejectionReason,
    );
    result.fold(
      (error) => emit(ResearchError(error: error)),
      (_) => emit(ResearchSuccess()),
    );
  }

  Future<void> approveResearch(String doctorUid, String paperId) async {
    emit(ResearchLoading());
    final result = await researchRepo.updatePaperStatus(
      doctorUid, paperId, VerificationStatus.approved,
    );
    result.fold(
      (error) => emit(ResearchError(error: error)),
      (_) => emit(ResearchSuccess()),
    );
  }

  Future<void> rejectResearch(String doctorUid, String paperId, String reason) async {
    emit(ResearchLoading());
    final result = await researchRepo.updatePaperStatus(
      doctorUid, paperId, VerificationStatus.rejected,
      rejectionReason: reason,
    );
    result.fold(
      (error) => emit(ResearchError(error: error)),
      (_) => emit(ResearchSuccess()),
    );
  }
}