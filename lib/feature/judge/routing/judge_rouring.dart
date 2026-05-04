import 'package:go_router/go_router.dart';
import 'package:optialeader/feature/judge/ui/screens/evaluation_screen_page.dart';

final List<RouteBase> judgeSubRoutes = [
  GoRoute(
    path: 'judgeEvaluation',
    builder: (context, state) => EvaluationScreen(),
  ),
];
