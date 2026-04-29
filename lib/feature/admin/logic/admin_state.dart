import 'package:equatable/equatable.dart';
import 'package:optialeader/feature/admin/data/model/admin_model.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

/// ================= INITIAL =================
class AdminInitial extends AdminState {}

/// ================= GET PROFILE =================
class AdminLoading extends AdminState {}

class AdminSuccess extends AdminState {
  final AdminModel admin;
  final String? message;

  const AdminSuccess(this.admin, {this.message});

  @override
  List<Object?> get props => [admin, message];
}

class AdminError extends AdminState {
  final String error;

  const AdminError(this.error);

  @override
  List<Object?> get props => [error];
}

/// ================= UPDATE =================
class AdminUpdateLoading extends AdminState {}

class AdminUpdateSuccess extends AdminState {
  final String message;

  const AdminUpdateSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminUpdateError extends AdminState {
  final String error;

  const AdminUpdateError(this.error);

  @override
  List<Object?> get props => [error];
}
