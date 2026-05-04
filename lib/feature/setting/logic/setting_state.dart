


import 'package:optialeader/feature/setting/data/models/user_setting_model.dart';

abstract class SettingState {}
class SettingInitial extends SettingState {}

class SettingLoading extends SettingState {}

class SettingFetchSuccess extends SettingState {
  final UserSettingsModel user;
  SettingFetchSuccess(this.user);
}
class SettingUpdateSuccess extends SettingState {}
class SettingError extends SettingState {
  final String message;
  SettingError(this.message);
}