import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/core/theming/logic/theme_cubit.dart';
import 'package:optialeader/feature/admin/data/repo/admin_repo_impl.dart';
import 'package:optialeader/feature/admin/data/repo/announcement_repos/announcement_repo_impl.dart';
import 'package:optialeader/feature/admin/logic/admin_cubit.dart';
import 'package:optialeader/feature/admin/logic/announcement_logic/announcement_cubit.dart';
import 'package:optialeader/feature/auth/data/repo/auth_repo_impl.dart';
import 'package:optialeader/feature/auth/logic/cubits/auth_cubit.dart';
import 'package:provider/single_child_widget.dart'; // ستحتاجين لهذا الـ import

class AppProviders {
  static List<SingleChildWidget> get providers => [
    BlocProvider(create: (context) => ThemeCubit()),
    BlocProvider(
      create: (context) => AuthCubit(
        AuthRepoImpl(
          auth: FirebaseAuth.instance,
          firestore: FirebaseFirestore.instance,
        ),
      ),
    ),
    // 3. نظام الأدمن (Profile & Settings)
    // 3. نظام الأدمن (Profile & Settings) - تم تصحيح القوس هنا
    BlocProvider(
      create: (context) =>
          AdminCubit(AdminRepoImpl(FirebaseFirestore.instance)),
    ),

    //      )..fetchAnnouncements(),عشان جيب الاعلانات اول ما يفتح

    BlocProvider(
      create: (context) => AnnouncementCubit(
        AnnouncementRepositoryImpl(FirebaseFirestore.instance),
      )..fetchAnnouncements(),
    ),
  ];
}
