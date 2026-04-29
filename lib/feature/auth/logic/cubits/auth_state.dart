import 'package:equatable/equatable.dart';
import 'package:optialeader/feature/auth/data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// ================= INITIAL =================
/// 🔴 المستخدم مش مسجل دخول
class AuthInitialState extends AuthState {}

/// ================= VERIFY =================
class VerifyLoadingState extends AuthState {}

class VerifySuccessState extends AuthState {
  final UserModel user;

  const VerifySuccessState(this.user);

  @override
  List<Object> get props => [user];
}

class VerifyErrorState extends AuthState {
  final String error;

  const VerifyErrorState(this.error);

  @override
  List<Object> get props => [error];
}

/// ================= SIGN UP =================
class SignUpLoadingState extends AuthState {}

class SignUpSuccessState extends AuthState {
  final UserModel userModel;

  const SignUpSuccessState(this.userModel);

  @override
  List<Object> get props => [userModel];
}

class SignUpErrorState extends AuthState {
  final String error;

  const SignUpErrorState(this.error);

  @override
  List<Object> get props => [error];
}

/// ================= LOGIN =================
class LoginLoadingState extends AuthState {}

/// 🟡 حالة UI فقط (اختياري تستخدمها في الشاشة)
class LoginSuccessState extends AuthState {
  final UserModel userModel;

  const LoginSuccessState(this.userModel);

  @override
  List<Object> get props => [userModel];
}

/// 🔴 خطأ في تسجيل الدخول
class LoginErrorState extends AuthState {
  final String error;

  const LoginErrorState(this.error);

  @override
  List<Object> get props => [error];
}

/// ================= AUTH FLOW (الأهم 🔥) =================

/// 🟡 أول تسجيل دخول → يروح يغير الباسورد
class NewUserFirstLoginState extends AuthState {
  final UserModel userModel;

  const NewUserFirstLoginState(this.userModel);

  @override
  List<Object> get props => [userModel];
}

/// ✅ المستخدم مسجل دخول (الحالة الأساسية للـ Router)
class AuthenticatedState extends AuthState {
  final UserModel userModel;

  const AuthenticatedState(this.userModel);

  @override
  List<Object> get props => [userModel];
}

/// ================= UPDATE PASSWORD =================
class UpdatePasswordLoadingState extends AuthState {}

class UpdatePasswordSuccessState extends AuthState {
  final String message;

  const UpdatePasswordSuccessState(this.message);

  @override
  List<Object> get props => [message];
}

class UpdatePasswordErrorState extends AuthState {
  final String error;

  const UpdatePasswordErrorState(this.error);

  @override
  List<Object> get props => [error];
}

/// ================= RESET PASSWORD =================
class PasswordResetLoadingState extends AuthState {}

class PasswordResetSuccessState extends AuthState {
  final String message;

  const PasswordResetSuccessState(this.message);

  @override
  List<Object> get props => [message];
}

class PasswordResetErrorState extends AuthState {
  final String error;

  const PasswordResetErrorState(this.error);

  @override
  List<Object> get props => [error];
}

/// ================= LOGOUT =================
class LogoutLoadingState extends AuthState {}

class LogoutSuccessState extends AuthState {}

class LogoutErrorState extends AuthState {
  final String error;

  const LogoutErrorState(this.error);

  @override
  List<Object> get props => [error];
}