import 'package:go_router/go_router.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/admin/ui/announces/announce.dart';
import 'package:optialeader/feature/admin/ui/announces/announce_dateail.dart';
import 'package:optialeader/feature/admin/ui/announces/edit_announcement.dart';

import 'package:optialeader/feature/admin/ui/request/full_employee_report_screen.dart';
import 'package:optialeader/feature/admin/ui/request/order_list_screen.dart';
import 'package:optialeader/feature/setting/ui/setting.dart';
import 'package:optialeader/feature/admin/ui/user_search_screen.dart';

final List<RouteBase> adminSubRoutes = [
  GoRoute(
    path: 'announcements',
    builder: (context, state) => const AnnouncementsPage(),
  ),

  GoRoute(
    path: 'orders-list',
    builder: (context, state) => OrdersListScreen(),
  ),
  
  GoRoute(
    path: 'fullEmployeeReport',
    builder: (context, state) => FullEmployeeReportScreen(),
  ),
  
  GoRoute(
    path: 'setting',
    builder: (context, state) {
      final args = state.extra as Map<String, dynamic>;
      return SettingsScreen(uid: args['uid'], role: args['role']);
    },
  ),
  
  GoRoute(
    path: 'user_search',
    builder: (context, state) => const UserSearchScreen(),
  ),
  
  GoRoute(
    path: 'announcementDetails',
    builder: (context, state) {
      final announcement = state.extra as AnnouncementModel;
      return AnnouncementDetailsPage(announcement: announcement);
    },
  ),
  
  GoRoute(
    path: 'editAnnountmentPage',
    builder: (context, state) {
      final announcement = state.extra as AnnouncementModel?;
      return EditAnnouncementPage(announcement: announcement);
    },
  ),
];