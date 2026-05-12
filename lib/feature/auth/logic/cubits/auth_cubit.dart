import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/auth/data/models/user_model.dart';
import 'package:optialeader/feature/auth/data/repo/auth_repo.dart';
import 'package:optialeader/feature/auth/logic/cubits/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;

  AuthCubit(this.authRepo) : super(AuthInitialState());

  // تسجيل الدخول وتحديد الوجهة
  Future<void> login({required String email, required String password}) async {
    emit(LoginLoadingState());
    final result = await authRepo.login(email: email, password: password);

    result.fold((error) => emit(LoginErrorState(error)), (userModel) {
      // 1. أولاً: نبعت حالة النجاح المؤقتة عشان الـ Router يلقطها ويبدأ الـ Redirect
      emit(LoginSuccessState(userModel));

      // 2. ثانياً: نحدد الحالة المستقرة (أول مرة دخول ولا دخول عادي)
      if (userModel.isFirstLogin) {
        emit(NewUserFirstLoginState(userModel));
      } else {
        emit(AuthenticatedState(userModel));
      }
    });
  }

  // إكمال إعداد الحساب (أول مرة بس)

  Future<void> completeFirstLogin({required String newPassword}) async {
    // 1. نأخذ نسخة من المستخدم الحالي من الحالة السابقة (Authenticated أو LoginSuccess)
    UserModel? currentUser;
    if (state is NewUserFirstLoginState) {
      currentUser = (state as NewUserFirstLoginState).userModel;
    } else if (state is LoginSuccessState) {
      currentUser = (state as LoginSuccessState).userModel;
    }

    if (currentUser != null) {
      // نبعت الـ user للـ Loading عشان يفضل متاح
      emit(UpdatePasswordLoadingState(currentUser));

      final result = await authRepo.completeFirstLogin(
        newPassword: newPassword,
      );

      result.fold((error) => emit(UpdatePasswordErrorState(error)), (message) {
        // نحدث قيمة isFirstLogin في النسخة اللي معانا
        final updatedUser = currentUser!.copyWith(isFirstLogin: false);

        emit(UpdatePasswordSuccessState(message, updatedUser));

        // 🔥 اللحظة الحاسمة: نبعت حالة Authenticated بالبيانات الجديدة
        // الـ Router هيشوف دي ويفتح الـ Dashboard فوراً بناءً على الـ Role
        emit(AuthenticatedState(updatedUser));
      });
    }
  }

  Future<void> logout() async {
    final result = await authRepo.logout();
    result.fold(
      (error) => emit(LoginErrorState(error)),
      (_) => emit(LogoutSuccessState()),
    );
  }
}
