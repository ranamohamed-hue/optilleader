import 'package:go_router/go_router.dart';
import 'package:optialeader/feature/admin/ui/request/order_list_screen.dart';
import 'package:optialeader/feature/judge/ui/screens/evaluation_screen_page.dart';
import 'package:optialeader/feature/setting/ui/setting.dart';

final List<RouteBase> judgeSubRoutes = [
  GoRoute(
    path: 'judgeEvaluation',
    builder: (context, state) => EvaluationScreen(),

  ),
  
  
  GoRoute(
    path: 'orders-list',
    builder: (context, state) => OrdersListScreen(),
  ),
];
