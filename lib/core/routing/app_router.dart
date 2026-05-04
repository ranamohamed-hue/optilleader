import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/routing/router_refresh_notifier.dart';
import 'package:optialeader/feature/admin/admin_routes.dart';
import 'package:optialeader/feature/admin/ui/dashboaer.dart';
import 'package:optialeader/feature/auth/logic/cubits/auth_cubit.dart';
import 'package:optialeader/feature/auth/ui/change_password_screen.dart';
import 'package:optialeader/feature/auth/ui/signin_screen.dart';
import 'package:optialeader/feature/auth/ui/signup_screen.dart';
import 'package:optialeader/feature/database_admin/routing/database_admin_routes.dart';
import 'package:optialeader/feature/judge/routing/judge_rouring.dart';
import 'package:optialeader/feature/judge/ui/screens/judge.dart';
import 'package:optialeader/feature/setting/ui/setting.dart';
import 'package:optialeader/feature/user/routing/user_routing.dart';
import 'package:optialeader/feature/user/ui/screens/dashboard_user.dart';
import 'package:optialeader/feature/auth/data/models/user_model.dart';

import 'package:optialeader/feature/database_admin/ui/screens/database_admin_dashboard.dart';
//عشان لنا اجي انتقل من مكان لاخ
import 'routes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
GoRouter createRouter(AuthCubit authCubit) {
  String getHomeByRole(UserRole role) {
    switch (role) {
      case UserRole.database_admin:
        return Routes.databaseAdmin;
      case UserRole.admin:
        return Routes.admin;
      case UserRole.judge:
        return Routes.judge;
      case UserRole.user:
        return Routes.user;
    }
  }

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: Routes.login,
    refreshListenable: RouterRefreshNotifier(authCubit),

    redirect: (context, state) {
      final authState = authCubit.state;

      final location = state.uri.toString();
      /*
      final isOnLogin = location == Routes.login;
      final isOnRegister = location == Routes.register;
      final isOnChangePassword = location == Routes.changePassword;

      // مش مسجل
      if (authState is AuthInitialState) {
        if (isOnLogin || isOnRegister) return null;
        return Routes.login;
      }

      // أول مرة
      if (authState is NewUserFirstLoginState) {
        if (isOnChangePassword) return null;
        return Routes.changePassword;
      }

      // مسجل
      if (authState is AuthenticatedState) {
        final role = authState.userModel.role;

        // يمنع الرجوع لصفحة تغيير الباسورد
        if (isOnChangePassword) {
          return getHomeByRole(role);
        }

        // يمنع الرجوع لصفحات auth
        if (isOnLogin || isOnRegister) {
          return getHomeByRole(role);
        }

        return null;
      }
*/
      return null;
    },

    routes: [
      /// AUTH
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const SignInView(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) => const SignUpView(),
      ),

      /// CHANGE PASSWORD
      GoRoute(
        path: Routes.changePassword,
        builder: (context, state) => const ChangePasswordView(),
      ),
      //DatabaseAdmin
      GoRoute(
        path: Routes.databaseAdmin,
        builder: (context, state) => const DatabaseAdminDashboard(),
        routes: databaseAdminSubRoutes,
      ),

      /// ADMIN
      GoRoute(
        path: Routes.admin,
        builder: (context, state) => const DashboardScreen(),
        routes: adminSubRoutes,
      ),

      /// JU
      GoRoute(
        path: Routes.judge,
        builder: (context, state) => const MohakemDashboardHome(),
      routes: judgeSubRoutes
      ),

      /// USER
      GoRoute(
        path: Routes.user,
        builder: (context, state) => const DashboardUserPage(),

        routes: userSubRoutes,
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return SettingsScreen(uid: args['uid'], role: args['role']);
        },
      ),
    ],
  );
}
