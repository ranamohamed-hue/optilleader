import 'package:go_router/go_router.dart';
import 'package:optialeader/feature/database_admin/ui/screens/add_admin_page.dart';
import 'package:optialeader/feature/database_admin/ui/screens/add_doctor_page.dart';
import 'package:optialeader/feature/database_admin/ui/screens/add_judge_page.dart'; // 🟢 استوردنا صفحة المحكم الجديدة
import 'package:optialeader/feature/database_admin/ui/screens/empolyee_search_page.dart';
import 'package:optialeader/feature/setting/ui/setting.dart';

final List<RouteBase> databaseAdminSubRoutes = [
  // 🟢 مسار البحث
  GoRoute(
    path: 'searchPage',
    builder: (context, state) => const UserSearchScreen(),
  ),
  
  GoRoute(
    path: 'addDoctorPage',
    builder: (context, state) {
      final String? existingUid = state.extra as String?;
      return AddDoctorPage(existingUid: existingUid); // 🟢 بقى يقرأ الـ UID
    },
  ),
  
  GoRoute(
    path: 'addAdminPage',
    builder: (context, state) {
      final String? existingUid = state.extra as String?;
      return AddAdminPage(existingUid: existingUid); // 🟢 بقى يقرأ الـ UID
    },
  ),
  
  GoRoute(
    path: 'addJudgePage',
    builder: (context, state) {
      final String? existingUid = state.extra as String?;
      return AddJudgePage(existingUid: existingUid); // 🟢 بقى يقرأ الـ UID واستخدمنا صفحة المحكم
    },
  ),
  
  GoRoute(
    path: 'setting',
    builder: (context, state) {
      final args = state.extra as Map<String, dynamic>;
      return SettingsScreen(
        uid: args['uid'],
        role: args['role'],
      );
    },
  ),
];