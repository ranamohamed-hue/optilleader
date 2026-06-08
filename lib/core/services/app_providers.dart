import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/core/services/hive_service.dart';
import 'package:optialeader/core/theming/logic/theme_cubit.dart';
import 'package:optialeader/feature/admin/data/repo/admin_approval/admin_aproval_repo_impl.dart';
import 'package:optialeader/feature/admin/data/repo/announcement_repos/announcement_repo_impl.dart';
import 'package:optialeader/feature/admin/logic/admin_approval/admin_approval_cubit.dart';
import 'package:optialeader/feature/admin/logic/announcement_logic/announcement_cubit.dart';
import 'package:optialeader/feature/auth/data/repo/auth_repo_impl.dart';
import 'package:optialeader/feature/auth/logic/cubits/auth_cubit.dart';
import 'package:optialeader/feature/database_admin/data/repo/admin_repository/admin_repo_impl.dart';
import 'package:optialeader/feature/database_admin/data/repo/database_admin_repository/database_admin_repo_impl.dart';
import 'package:optialeader/feature/database_admin/data/repo/doctor_repository/doctor_repo_impl.dart';
import 'package:optialeader/feature/database_admin/data/repo/judge_repository/judge_repo_impl.dart';
import 'package:optialeader/feature/database_admin/data/repo/search/search_repo.dart';
import 'package:optialeader/feature/database_admin/logic/admin_data/admin_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/database_admin_data/databse_admin_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/judge_data/judge_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/search/search_cubit.dart';
import 'package:optialeader/feature/doctor/data/repo/activities/activity_repo_impl.dart';
import 'package:optialeader/feature/doctor/data/repo/research_paper/research_paper_repo_impl.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo_impl.dart';
import 'package:optialeader/feature/notification/logic/app_notification_cubit.dart';
import 'package:optialeader/feature/setting/data/repo/setting_repo_impl.dart';
import 'package:optialeader/feature/setting/logic/setting_cubit.dart';
import 'package:provider/single_child_widget.dart';

class AppProviders {
  static List<SingleChildWidget> providers({
    required HiveService hiveService,
  }) => [
    // كيوبيت الثيم
    BlocProvider(create: (context) => ThemeCubit()),
    
    // كيوبيت المصادقة
    BlocProvider(
      create: (context) => AuthCubit(
        AuthRepoImpl(
          auth: FirebaseAuth.instance,
          firestore: FirebaseFirestore.instance,
          hiveService: hiveService,
        ),
      ),
    ),
    
    // كيوبيت الادمن
    BlocProvider(create: (context) => AdminDataCubit(AdminRepoImpl())),
    
    // كيوبيت الدكتور
    BlocProvider(create: (context) => DoctorDataCubit(DoctorRepoImpl())),
    
    // كيوبيت المحكم
    BlocProvider(create: (context) => JudgeDataCubit(JudgeRepoImpl())),
    
    // كيوبيت مسؤول قاعدة البيانات
    BlocProvider(
      create: (context) => DatabseAdminCubit(DatabaseAdminRepoImpl(FirebaseFirestore.instance)),
    ),
    
    // كيوبيت الاعلانات
   // كيوبيت الاعلانات
BlocProvider(
  create: (context) => AnnouncementCubit(
    AnnouncementRepositoryImpl(FirebaseFirestore.instance),
    context.read<NotificationRepoImpl>(), 
    FirebaseFirestore.instance,           
  )..fetchAnnouncements(),
),
    
    // كيوبيت الاعدادات
    BlocProvider(create: (context) => SettingCubit(SettingRepoImpl())),
    
    // كيوبيت البحث
    BlocProvider(
      create: (context) => SearchCubit(SearchRepo(FirebaseFirestore.instance)),
    ),
    
    // توفير الـ Repos باستخدام RepositoryProvider
    RepositoryProvider(create: (context) => ResearchPaperRepoImpl()),
    RepositoryProvider(create: (context) => ActivityRepoImpl()),
    RepositoryProvider(create: (context) => NotificationRepoImpl()),

    // كيوبيت الإشعارات (بناخد الـ Repo من الـ RepositoryProvider)
    BlocProvider(
      create: (context) {
        final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
        return NotificationCubit(
          notificationRepo: context.read<NotificationRepoImpl>(),
          userId: uid,
        );
      },
    ),

    //  كيوبيت الموافقات للأدمن (بناخد الـ Repos من الـ RepositoryProvider)
    BlocProvider(
      create: (context) => AdminApprovalCubit(
        adminApprovalRepo: AdminApprovalRepoImpl(
          firebaseFirestore: FirebaseFirestore.instance,
          researchPaperRepo: context.read<ResearchPaperRepoImpl>(),
          activityRepo: context.read<ActivityRepoImpl>(),
          notificationRepo: context.read<NotificationRepoImpl>(),
        ),
      ),
    ),
  ];
}