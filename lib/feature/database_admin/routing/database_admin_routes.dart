import 'package:go_router/go_router.dart';
import 'package:optialeader/feature/database_admin/ui/screens/add_admin_page.dart';
import 'package:optialeader/feature/database_admin/ui/screens/add_doctor_page.dart';
import 'package:optialeader/feature/setting/ui/setting.dart';


final List<RouteBase> databaseAdminSubRoutes=[
  GoRoute(path: 'addDoctorPage',
  builder: (context, state) => const AddDoctorPage(),
  ),
  GoRoute(path: 'addAdminPage',
  builder: (context, state) => const AddAdminPage(),),
  GoRoute(path: 'addJudgePage',
  builder: (context, state) => const AddAdminPage(),),
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