import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/admin/data/repo/announcement_repos/announcement_repo_impl.dart';
import 'announcement_state.dart';

class AnnouncementCubit extends Cubit<AnnouncementState> {
  final AnnouncementRepositoryImpl _repository;

  AnnouncementCubit(this._repository) : super(AnnouncementInitial());

  void fetchAnnouncements() {
    emit(AnnouncementLoading());
    _repository.getAnnouncements().listen(
      (data) => emit(AnnouncementLoaded(data)),
      onError: (error) =>
          emit( AnnouncementError("ERROR_FETCH_ANNOUNCEMENTS")), // ✅
    );
  }

  Future<void> addAnnouncement(AnnouncementModel announcement) async {
    emit(AnnouncementLoading());
    final result = await _repository.addAnnouncement(announcement);
    result.fold(
      (error) => emit(AnnouncementError(error)),
      (_) => emit(
         AnnouncementActionSuccess("SUCCESS_ADD_ANNOUNCEMENT"),
      ), // ✅
    );
  }

  Future<void> updateAnnouncement(AnnouncementModel announcement) async {
    final result = await _repository.updateAnnouncement(announcement);
    result.fold(
      (error) => emit(AnnouncementError(error)),
      (_) => emit(
         AnnouncementActionSuccess("SUCCESS_UPDATE_ANNOUNCEMENT"),
      ), // ✅
    );
  }

  Future<void> deleteAnnouncement(String id) async {
    final result = await _repository.deleteAnnouncement(id);
    result.fold(
      (error) => emit(AnnouncementError(error)),
      (_) => emit(
         AnnouncementActionSuccess("SUCCESS_DELETE_ANNOUNCEMENT"),
      ), // ✅
    );
  }
}
