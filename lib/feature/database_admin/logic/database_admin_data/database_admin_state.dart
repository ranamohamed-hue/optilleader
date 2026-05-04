


import 'package:optialeader/feature/database_admin/data/models/database_admin_model.dart';

abstract class DatabaseAdminState {}

class DatabaseAdminInitial extends DatabaseAdminState {}
class DatabaseAdminLoading extends DatabaseAdminState {}
class DatabaseAdminSuccess extends DatabaseAdminState {
  final DatabaseAdminProfileModel profile;
  DatabaseAdminSuccess(this.profile);
}
class DatabaseAdminError extends DatabaseAdminState {
  final String message;
  DatabaseAdminError(this.message);
}
class DatabaseAdminUpdateSuccess extends DatabaseAdminState {}