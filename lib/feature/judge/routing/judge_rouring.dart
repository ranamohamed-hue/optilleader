import 'package:go_router/go_router.dart';
import 'package:optialeader/feature/admin/data/model/nomination_request_model.dart';
import 'package:optialeader/feature/judge/ui/screens/evaluation_screen_page.dart';
import 'package:optialeader/feature/judge/ui/screens/judge_orders_list_screen.dart';

final List<RouteBase> judgeSubRoutes = [
  GoRoute(
    path: 'evaluationScreen',
    builder: (context, state) {
      // استقبال موديل الطلب بالكامل
      final request = state.extra as NominationRequestModel;
      // تمرير الـ ID للشاشة
      return InterviewEvaluationScreen(
        requestId: request.id ?? "",
      );
    },
  ),
  GoRoute(
    path: 'orders-list',
    builder: (context, state) {
      // ✅ استقبال خريطة الفلاتر (Status & Role)
      final args = state.extra as Map<String, dynamic>?;
      return JudgeOrdersListScreen(
        filterStatus: args?['status'],
        filterRole: args?['role'],
      );
    },
  ),
];