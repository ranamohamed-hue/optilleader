import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:easy_localization/easy_localization.dart'; 
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/auth/data/models/user_model.dart';
import 'package:optialeader/feature/auth/data/repo/auth_repo.dart';
import 'package:optialeader/feature/auth/logic/cubits/auth_state.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart'; 
import 'package:optialeader/feature/notification/data/repo/notification_repo_impl.dart'; 

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  final NotificationRepoImpl notificationRepo; 

  AuthCubit(this.authRepo, this.notificationRepo) : super(AuthInitialState()) { 
    checkAuthStatus();
  }

  void checkAuthStatus() {
    final cachedUser = authRepo.getCachedUser(); 

    if (cachedUser != null) {
      if (cachedUser.isFirstLogin) {
        emit(NewUserFirstLoginState(cachedUser));
      } else {
        emit(AuthenticatedState(cachedUser));
      }
    } else {
      emit(AuthInitialState());
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(LoginLoadingState());
    final result = await authRepo.login(email: email, password: password);

    result.fold((error) => emit(LoginErrorState(error)), (userModel) {
      if (userModel.isFirstLogin) {
        emit(NewUserFirstLoginState(userModel));
      } else {
        emit(AuthenticatedState(userModel));
      }
    });
  }

  // إكمال إعداد الحساب (أول مرة بس)
  Future<void> completeFirstLogin({required String newPassword}) async {
    UserModel? currentUser;
    if (state is NewUserFirstLoginState) {
      currentUser = (state as NewUserFirstLoginState).userModel;
    } else if (state is LoginSuccessState) {
      currentUser = (state as LoginSuccessState).userModel;
    }

    if (currentUser != null) {
      emit(UpdatePasswordLoadingState(currentUser));

      final result = await authRepo.completeFirstLogin(
        newPassword: newPassword,
      );

      result.fold((error) => emit(UpdatePasswordErrorState(error)), (message) {

        final updatedUser = currentUser!.copyWith(isFirstLogin: false);
        emit(UpdatePasswordSuccessState(message, updatedUser));
        emit(AuthenticatedState(updatedUser));

        // إرسال إشعار ترحيبي بعد تغيير الباسورد بنجاح
        _sendWelcomeNotification(updatedUser);
      });
    }
  }

  //  دالة إرسال إشعار الترحيب حسب دور المستخدم 
  Future<void> _sendWelcomeNotification(UserModel user) async {
    try {
      String title;
      String message;
      NotificationType type = NotificationType.general;

      // استخدام مفاتيح الترجمة بدل النصوص الثابتة
      switch (user.role) {
        case UserRole.user: // الدكتور
          title = 'welcome_notifications.title_doctor'.tr();
          message = 'welcome_notifications.message_doctor'.tr();
          type = NotificationType.welcomeDoctor;
          break;
        case UserRole.admin:
          title = 'welcome_notifications.title_admin'.tr();
          message = 'welcome_notifications.message_admin'.tr();
          type = NotificationType.welcomeAdmin;
          break;
        case UserRole.judge:
          title = 'welcome_notifications.title_judge'.tr();
          message = 'welcome_notifications.message_judge'.tr();
          type = NotificationType.welcomeJudge;
          break;
        case UserRole.database_admin:
          title = 'welcome_notifications.title_db_admin'.tr();
          message = 'welcome_notifications.message_db_admin'.tr();
          type = NotificationType.welcomeAdmin; 
          break;
      }

      // إنشاء وبعث الإشعار
      final notification = AppNotificationModel(
        id: '',
        title: title,
        message: message,
        type: type,
        timestamp: Timestamp.now(),
        receiverId: user.uid,
      );

      await notificationRepo.sendNotification(notification);
      
    } catch (e) {
      print("فشل إرسال إشعار الترحيب: $e");
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