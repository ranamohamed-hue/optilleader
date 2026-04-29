import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/auth/data/models/user_model.dart';
import 'package:optialeader/feature/auth/data/repo/auth_repo.dart';
import 'package:optialeader/feature/auth/logic/cubits/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;

  AuthCubit(this.authRepo) : super(AuthInitialState());

  /// ================== 🔍 VERIFY ==================
  Future<void> verifyUser({
    required String email,
    required String nationalId,
    required String employeeId,
  }) async {
    emit(VerifyLoadingState());

    final result = await authRepo.verifyUser(
      email: email,
      nationalId: nationalId,
      employeeId: employeeId,
    );

    result.fold(
      (error) => emit(VerifyErrorState(error)),
      (user) => emit(VerifySuccessState(user)),
    );
  }

  /// ================== 🆕 SIGN UP ==================
  Future<void> signUp({
    required UserModel userModel,
    required String password,
  }) async {
    emit(SignUpLoadingState());

    final result = await authRepo.signUp(
      userModel: userModel,
      password: password,
    );

    result.fold(
      (error) => emit(SignUpErrorState(error)),
      (user) => emit(SignUpSuccessState(user)),
    );
  }

  /// ================== 🔐 LOGIN ==================
  Future<void> login({required String email, required String password}) async {
    emit(LoginLoadingState());

    final result = await authRepo.login(email: email, password: password);

    result.fold((error) => emit(LoginErrorState(error)), (userModel) {
      /// 🛡️ Safety
      if (!userModel.isRegistered) {
        emit(LoginErrorState("الحساب غير مكتمل التسجيل"));
        return;
      }

      if (userModel.universityEmail.isEmpty) {
        emit(LoginErrorState("بيانات غير صحيحة"));
        return;
      }

      /// 🟡 First Login
      if (userModel.isFirstLogin) {
        emit(NewUserFirstLoginState(userModel));
      } else {
        emit(LoginSuccessState(userModel));
      }
    });
  }

  /// ================== 🔁 FIRST LOGIN ==================
  Future<void> completeFirstLogin({required String newPassword}) async {
    emit(UpdatePasswordLoadingState());

    final result = await authRepo.completeFirstLogin(newPassword: newPassword);

    result.fold((error) => emit(UpdatePasswordErrorState(error)), (message) {
      final currentState = state;

      /// 🔥 أهم جزء
      if (currentState is NewUserFirstLoginState) {
        emit(AuthenticatedState(currentState.userModel));
      } else {
        emit(UpdatePasswordSuccessState(message));
      }
    });
  }

  /// ================== 📩 RESET ==================
  Future<void> resetPassword({required String email}) async {
    emit(PasswordResetLoadingState());

    final result = await authRepo.sendPasswordResetEmail(email: email);

    result.fold(
      (error) => emit(PasswordResetErrorState(error)),
      (message) => emit(PasswordResetSuccessState(message)),
    );
  }

  /// ================== 🚪 LOGOUT ==================
  Future<void> logout() async {
    emit(LogoutLoadingState());

    final result = await authRepo.logout();

    result.fold(
      (error) => emit(LogoutErrorState(error)),
      (_) => emit(LogoutSuccessState()),
    );
  }
}
