import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/core/services/hive_service.dart';
import 'package:optialeader/core/theming/logic/theme_cubit.dart';
import 'package:optialeader/feature/admin/data/repo/admin_approval/admin_aproval_repo_impl.dart';
import 'package:optialeader/feature/admin/data/repo/announcement_repos/announcement_repo_impl.dart';

// ✅ الإضافة الجديدة: استيراد الريبو الخاص بالطلبات
import 'package:optialeader/feature/admin/data/repo/nomination_request/nomination_request_repo.dart';
import 'package:optialeader/feature/admin/data/repo/nomination_request/nomination_request_repo_impl.dart';

import 'package:optialeader/feature/admin/logic/admin_approval/admin_approval_cubit.dart';
import 'package:optialeader/feature/admin/logic/announcement_logic/announcement_cubit.dart';

// ✅ الإضافة الجديدة: استيراد الكيوبيت الخاص بالطلبات
import 'package:optialeader/feature/admin/logic/nomination_request_logic/nomination_request_cubit.dart';
import 'package:supabase/supabase.dart';
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
import 'package:optialeader/feature/doctor/data/repo/research_paper/research_paper_repo.dart';
import 'package:optialeader/feature/doctor/data/repo/research_paper/research_paper_repo_impl.dart';
import 'package:optialeader/feature/doctor/logic/activities/activity_cubit.dart';
import 'package:optialeader/feature/doctor/logic/research_paper/research_paper_cubit.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo_impl.dart';
import 'package:optialeader/feature/notification/logic/app_notification_cubit.dart';
import 'package:optialeader/feature/setting/data/repo/setting_repo_impl.dart';
import 'package:optialeader/feature/setting/logic/setting_cubit.dart';
import 'package:provider/single_child_widget.dart';

import 'package:optialeader/feature/doctor/data/repo/activities/activity_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 

class AppProviders {
  static List<SingleChildWidget> providers({
    required HiveService hiveService,
  }) => [
   
    RepositoryProvider<ResearchPaperRepo>(create: (context) => ResearchPaperRepoImpl()),
    RepositoryProvider<ActivityRepo>(create: (context) => ActivityRepoImpl()),
    RepositoryProvider<NotificationRepo>(create: (context) => NotificationRepoImpl()),
    


RepositoryProvider<NominationRequestRepository>(
  create: (context) => NominationRequestRepositoryImpl(
    FirebaseFirestore.instance,
    Supabase.instance.client, // ✅ تمرير Supabase Client
  ),
),

    // -------------------------------------------------------------
    // ✅ الـ Cubits
    // -------------------------------------------------------------
    
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
      create: (context) =>
          DatabseAdminCubit(DatabaseAdminRepoImpl(FirebaseFirestore.instance)),
    ),

    // كيوبيت الاعلانات
    BlocProvider(
      create: (context) => AnnouncementCubit(
        AnnouncementRepositoryImpl(FirebaseFirestore.instance),
        context.read<NotificationRepo>(),
      )..fetchAnnouncements(),
    ),

    // كيوبيت الاعدادات
    BlocProvider(create: (context) => SettingCubit(SettingRepoImpl())),

    // كيوبيت البحث
    BlocProvider(
      create: (context) => SearchCubit(SearchRepo(FirebaseFirestore.instance)),
    ),

    // كيوبيت الأنشطة
    BlocProvider(
      create: (context) => ActivityCubit(
        context.read<ActivityRepo>(),
        context.read<NotificationRepo>(),
      ),
    ),

    // كيوبيت الأبحاث
    BlocProvider(
      create: (context) => ResearchCubit(
        context.read<ResearchPaperRepo>(),
        context.read<NotificationRepo>(),
      ),
    ),

    // كيوبيت الإشعارات
    BlocProvider(
      create: (context) {
        final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
        return NotificationCubit(
          notificationRepo: context.read<NotificationRepo>(),
          userId: uid,
        )..fetchNotifications();
      },
    ),

    // كيوبيت الموافقات للأدمن
    BlocProvider(
      create: (context) => AdminApprovalCubit(
        adminApprovalRepo: AdminApprovalRepoImpl(
          firebaseFirestore: FirebaseFirestore.instance,
          researchPaperRepo: context.read<ResearchPaperRepo>(),
          activityRepo: context.read<ActivityRepo>(),
          notificationRepo: context.read<NotificationRepo>(),
        ),
      ),
    ),

    // ✅ الإضافة الجديدة: كيوبيت طلبات الترشح (متاح لكل المستخدمين)
    BlocProvider(
      create: (context) => NominationRequestCubit(
        context.read<NominationRequestRepository>(), // قراءة الريبو
        context.read<NotificationRepo>(),            // قراءة ريبو الإشعارات
      ),
    ),
  ];
}