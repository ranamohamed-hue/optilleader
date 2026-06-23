import 'package:go_router/go_router.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/admin/data/model/nomination_request_model.dart';
import 'package:optialeader/feature/admin/ui/announces/announce.dart';
import 'package:optialeader/feature/admin/ui/announces/edit_announcement.dart';
import 'package:optialeader/feature/admin/ui/admin_pending_requests_page.dart';
import 'package:optialeader/feature/admin/ui/admin_details_page.dart';
import 'package:optialeader/feature/admin/ui/request/order_list_screen.dart';
import 'package:optialeader/feature/admin/ui/user_search_screen.dart';
import 'package:optialeader/feature/admin/ui/request/nomination_requestd_details_screen.dart';

final List<RouteBase> adminSubRoutes = [
  // 1. شاشة إعلانات الإدمن
  GoRoute(
    path: 'announcements',
    builder: (context, state) => const AnnouncementsPage(),
  ),

  // 2. شاشة قائمة الطلبات
  GoRoute(
    path: 'orders-list',
    builder: (context, state) => const OrdersListScreen(),
  ),

  // 3. تفاصيل طلب الترشح (الشاشة الجديدة)
  GoRoute(
    path: 'nomination-request-details',
    builder: (context, state) {
      final request = state.extra as NominationRequestModel;
      return NominationRequestDetailsScreen(request: request);
    },
  ),

  // 4. الإعدادات
 /* GoRoute(
    path: 'setting',
    builder: (context, state) {
      final args = state.extra as Map<String, dynamic>;
      return SettingsScreen(uid: args['uid'], role: args['role']);
    },
  ),*/

  // 5. البحث عن مستخدم
  GoRoute(
    path: 'user-search',
    builder: (context, state) => const UserSearchScreen(),
  ),

  // 6. تفاصيل الإعلان
  GoRoute(
    path: 'announcement-details',
    builder: (context, state) {
      final announcement = state.extra as AnnouncementModel;
      return AnnouncementDetailsPage(announcement: announcement);
    },
  ),

  // 7. تعديل الإعلان
  GoRoute(
    path: 'edit-announcement',
    builder: (context, state) {
      final announcement = state.extra as AnnouncementModel?;
      return EditAnnouncementPage(announcement: announcement);
    },
  ),

  // 8. طلبات الأبحاث والأنشطة المعلقة
  GoRoute(
    path: 'pending-requests',
    builder: (context, state) => const AdminPendingRequestsPage(),
    routes: [
      GoRoute(
        path: 'details',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return AdminDetailsPage(
            item: args['item'],
            doctorUid: args['doctorUid'],
            type: args['type'],
          );
        },
      ),
    ],
  ),
];