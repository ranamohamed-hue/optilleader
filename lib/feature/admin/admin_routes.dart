import 'package:go_router/go_router.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/admin/ui/announces/announce.dart';
import 'package:optialeader/feature/admin/ui/announces/announce_dateail.dart';
import 'package:optialeader/feature/admin/ui/announces/edit_announcement.dart';
import 'package:optialeader/feature/admin/ui/setting.dart';
import 'package:optialeader/feature/admin/ui/sxas.dart';
import 'package:optialeader/feature/admin/ui/user_search_screen.dart';

final List<RouteBase> adminSubRoutes = [
  GoRoute(
    path: 'announcements',
    builder: (context, state) => const AnnouncementsPage(),
  ),

  GoRoute(
    path: 'orders-list',
    builder: (context, state) => const OrdersListScreen(),
  ),
  GoRoute(
    path: 'admin_setting',
    builder: (context, state) => const AdminSettingsScreen(),
  ),
  GoRoute(
    path: 'user_search',
    builder: (context, state) => const UserSearchScreen(),
  ),
  GoRoute(
    path: 'announcementDetails',
    builder: (context, state) {
      final announcement = state.extra as AnnouncementModel; // استقبال الموديل
      return AnnouncementDetailsPage(announcement: announcement);
    },
  ),
  GoRoute(
    path: 'editAnnountmentPage', // خدي بالك من الإملاء هنا لو قصدك Announcement
    builder: (context, state) {
      final announcement = state.extra as AnnouncementModel; 
      return EditAnnouncementPage(announcement: announcement);
    },
  ),
];
