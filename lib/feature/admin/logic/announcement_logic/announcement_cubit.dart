import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/admin/data/repo/announcement_repos/announcement_repo_impl.dart';

import 'announcement_state.dart';

class AnnouncementCubit extends Cubit<AnnouncementState> {
  final AnnouncementRepositoryImpl _repository;

  AnnouncementCubit(this._repository) : super(AnnouncementInitial());

  // 1. جلب الإعلانات بشكل لحظي (Stream)
  void fetchAnnouncements() {
    emit(AnnouncementLoading());
    _repository.getAnnouncements().listen(
      (data) {
        emit(AnnouncementLoaded(data));
      },
      onError: (error) {
        emit(AnnouncementError("عفواً، حدث خطأ أثناء جلب البيانات"));
      },
    );
  }

  // 2. إضافة إعلان جديد
  Future<void> addAnnouncement(AnnouncementModel announcement) async {
    emit(AnnouncementLoading());
    try {
      await _repository.addAnnouncement(announcement);
      emit(AnnouncementActionSuccess("تم إضافة الإعلان بنجاح"));
    } catch (e) {
      emit(AnnouncementError("فشل إضافة الإعلان، حاول مرة أخرى"));
    }
  }

  // 3. تعديل إعلان
  Future<void> updateAnnouncement(AnnouncementModel announcement) async {
    try {
      await _repository.updateAnnouncement(announcement);
      emit(AnnouncementActionSuccess("تم تحديث الإعلان بنجاح"));
    } catch (e) {
      emit(AnnouncementError("فشل التحديث"));
    }
  }

  // 4. حذف إعلان
  Future<void> deleteAnnouncement(String id) async {
    try {
      await _repository.deleteAnnouncement(id);
      emit(AnnouncementActionSuccess("تم حذف الإعلان"));
    } catch (e) {
      emit(AnnouncementError("فشل الحذف"));
    }
  }
}
