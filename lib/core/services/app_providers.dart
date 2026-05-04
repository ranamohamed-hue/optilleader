import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/core/theming/logic/theme_cubit.dart';
import 'package:optialeader/feature/admin/data/repo/announcement_repos/announcement_repo_impl.dart';
import 'package:optialeader/feature/admin/logic/announcement_logic/announcement_cubit.dart';
import 'package:optialeader/feature/auth/data/repo/auth_repo_impl.dart';
import 'package:optialeader/feature/auth/logic/cubits/auth_cubit.dart';
import 'package:optialeader/feature/database_admin/data/repo/admin_repository/admin_repo_impl.dart';
import 'package:optialeader/feature/database_admin/data/repo/database_admin_repository/database_admin_repo_impl.dart';
import 'package:optialeader/feature/database_admin/data/repo/doctor_repository/doctor_repo_impl.dart';
import 'package:optialeader/feature/database_admin/data/repo/judge_repository/judge_repo_impl.dart';
import 'package:optialeader/feature/database_admin/logic/admin_data/admin_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/judge_data/judge_data_cubit.dart';
import 'package:optialeader/feature/setting/data/repo/setting_repo_impl.dart';
import 'package:optialeader/feature/setting/logic/setting_cubit.dart';
import 'package:provider/single_child_widget.dart'; 
import 'package:optialeader/feature/database_admin/logic/database_admin_data/databse_admin_cubit.dart';

class AppProviders {
  static List<SingleChildWidget> get providers => [
    //كيوبيت الثيم
    BlocProvider(create: (context) => ThemeCubit()),
    //كيوبيت المصادقة
    BlocProvider(
      create: (context) => AuthCubit(
        AuthRepoImpl(
          auth: FirebaseAuth.instance,
          firestore: FirebaseFirestore.instance,
        ),
      ),
    ),
    //كيوبيت الادمن
    BlocProvider(create: (context) => AdminDataCubit(AdminRepoImpl())),
    // كيوبيت الدكتور
    BlocProvider(create: (context) => DoctorDataCubit(DoctorRepoImpl())),
    //كيوبيت المحكم
    BlocProvider(create: (context) => JudgeDataCubit(JudgeRepoImpl())),
    //كيوبيت مسؤول قاعدة البيانات
    BlocProvider(
      create: (context) =>
          DatabseAdminCubit(DatabaseAdminRepoImpl(FirebaseFirestore.instance)),
    ),
    //كيوبيت الاعلانات
    BlocProvider(
      create: (context) => AnnouncementCubit(
        AnnouncementRepositoryImpl(FirebaseFirestore.instance),
      )..fetchAnnouncements(),
    ),
    //كيوبيت الاعدادات
    BlocProvider(create: (context) => SettingCubit(SettingRepoImpl())),
  ];
}
