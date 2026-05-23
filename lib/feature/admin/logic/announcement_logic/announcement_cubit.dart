import 'dart:io'; // ✅ لاستخدام File
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/admin/data/repo/announcement_repos/announcement_repo.dart'; // ✅ نستخدم الـ Interface
import 'announcement_state.dart';

class AnnouncementCubit extends Cubit<AnnouncementState> {
  final IAnnouncementRepository _repository; // ✅ [تعديل] استخدام الـ Interface

  AnnouncementCubit(this._repository) : super(AnnouncementInitial());

  void fetchAnnouncements() {
    emit(AnnouncementLoading());
    _repository.getAnnouncements().listen(
      (data) => emit(AnnouncementLoaded(data)),
      onError: (error) => emit(AnnouncementError("ERROR_FETCH_ANNOUNCEMENTS")),
    );
  }

  // ✅ [تعديل] إضافة احتمالية رفع صورة أثناء الإضافة
  Future<void> addAnnouncement(AnnouncementModel announcement, {String? imagePath}) async {
    emit(AnnouncementLoading());
    
    // 1. لو فيه صورة، ارفعها الأول
    if (imagePath != null) {
      final uploadResult = await _repository.uploadAnnouncementImage(imagePath);
      String? finalImageUrl;
      uploadResult.fold(
        (error) {
          emit(AnnouncementError(error));
          return; // لو الصورة فشلت، نقف
        }, 
        (url) => finalImageUrl = url,
      );
      
      // 2. حدث الموديل بالرابط الجديد
      if (finalImageUrl != null) {
        announcement = announcement.copyWith(imageUrl: finalImageUrl);
      }
    }

    // 3. احفظ الإعلان في Firestore
    final result = await _repository.addAnnouncement(announcement);
    result.fold(
      (error) => emit(AnnouncementError(error)),
      (_) => emit(AnnouncementActionSuccess("SUCCESS_ADD_ANNOUNCEMENT")),
    );
  }

  // ✅ [تعديل] إضافة احتمالية تغيير الصورة أثناء التعديل
  Future<void> updateAnnouncement(AnnouncementModel announcement, {String? imagePath}) async {
    emit(AnnouncementLoading());
    
    if (imagePath != null) {
      final uploadResult = await _repository.uploadAnnouncementImage(imagePath);
      String? finalImageUrl;
      uploadResult.fold(
        (error) {
          emit(AnnouncementError(error));
          return;
        }, 
        (url) => finalImageUrl = url,
      );
      
      if (finalImageUrl != null) {
        announcement = announcement.copyWith(imageUrl: finalImageUrl);
      }
    }

    final result = await _repository.updateAnnouncement(announcement);
    result.fold(
      (error) => emit(AnnouncementError(error)),
      (_) => emit(AnnouncementActionSuccess("SUCCESS_UPDATE_ANNOUNCEMENT")),
    );
  }

  // ✅ [تعديل] تمرير الـ imageUrl لدالة الحذف
  Future<void> deleteAnnouncement(String id, String? imageUrl) async {
    final result = await _repository.deleteAnnouncement(id, imageUrl);
    result.fold(
      (error) => emit(AnnouncementError(error)),
      (_) => emit(AnnouncementActionSuccess("SUCCESS_DELETE_ANNOUNCEMENT")),
    );
  }
}