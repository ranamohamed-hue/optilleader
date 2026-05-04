import 'package:bloc/bloc.dart';
import 'package:optialeader/feature/setting/data/models/user_setting_model.dart';
import 'package:optialeader/feature/setting/data/repo/setting_repo.dart';
import 'package:optialeader/feature/setting/logic/setting_state.dart';

class SettingCubit extends Cubit<SettingState> {
  final SettingsRepo _settingsRepo;
  SettingCubit(this._settingsRepo) : super(SettingInitial());
  Future<void> getUserData({required String uid, required String role}) async {
    emit(SettingLoading());
    final result = await _settingsRepo.getUserData(uid: uid, role: role);
    result.fold(
      (error) => emit(SettingError(error)),
      (userModel) => emit(SettingFetchSuccess(userModel)),
    );
  }

  Future<void> updateUserData({
    required UserSettingsModel user,
    required String role,
  }) async {
    emit(SettingLoading());

    final result = await _settingsRepo.updateProfileData(
      user: user,
      role: role,
    );

    result.fold(
      (error) => emit(SettingError(error)),
      (success) => emit(SettingUpdateSuccess()),
    );
  }
}
