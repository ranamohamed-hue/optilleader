import 'package:optialeader/feature/database_admin/logic/leadership_scoring_engine/leadership_scoring_engine.dart';

abstract class LeadershipState {}
class LeadershipInitial extends LeadershipState {}
class LeadershipLoading extends LeadershipState {}

// ✅ للصفحات التانية (لو محتاجهم لوحدهم)
class LeadershipScoreLoaded extends LeadershipState {
  final int coursePoints;
  LeadershipScoreLoaded({required this.coursePoints});
}

class Article22Loaded extends LeadershipState {
  final Map<String, double> participationMap;
  Article22Loaded({required this.participationMap});
}

class MandatoryCriteriaLoaded extends LeadershipState {
  final List<CriterionStatus> criteria;
  MandatoryCriteriaLoaded({required this.criteria});
}

// ✅✅ الـ State الجديدة لصفحة التقديم (بتجمع الدرجات والشروط)
class NominationDataLoaded extends LeadershipState {
  final Map<String, dynamic> scores;
  final List<CriterionStatus> criteria;

  NominationDataLoaded({required this.scores, required this.criteria});
}

class LeadershipError extends LeadershipState {
  final String message; // ✅ خليها Key للترجمة
  LeadershipError(this.message);
}