import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/database_admin/data/models/judge_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/judge_data/judge_data_state.dart';
import 'package:optialeader/feature/database_admin/data/repo/judge_repository/judge_repo.dart';

class JudgeDataCubit extends Cubit<JudgeDataState> {
  final JudgeRepo judgeRepo;
  StreamSubscription? _judgesSubscription;
  JudgeDataCubit(this.judgeRepo) : super(JudgeInitial());
  Future<void> getJudgeProfile(String uid) async {
    emit(JudgeLoading());
    final result = await judgeRepo.getJudgeProfile(uid);
    result.fold(
      (error) => emit(JudgeError(error: error)),
      (judge) => emit(JudgeLoaded(judge: judge)),
    );
  }

  Future<void> saveJudgeData(JudgeProfileModel judge) async {
    emit(JudgeLoading());
    final result = await judgeRepo.saveJudgeData(judge);
    result.fold(
      (error) => emit(JudgeError(error: error)),
      (_) => emit(JudgeSuccess()),
    );
  }

  void watchAllJudges() {
    emit(JudgeLoading());
    _judgesSubscription?.cancel();
    _judgesSubscription = judgeRepo.watchAllJudges().listen(
      (judgesList) {
        emit(AllJudgesLoaded(judges: judgesList));
      },
      onError: (error) {
        emit(JudgeError(error: error.toString()));
      },
    );
  }

  Future<void> deleteJudge(String uid) async {
    emit(JudgeDeleting());
    final result = await judgeRepo.deleteJudgeAccount(uid);
    result.fold(
      (error) => emit(JudgeError(error: error)),
      (_) => emit(JudgeSuccess()),
    );
  }

  @override
  Future<void> close() {
    _judgesSubscription?.cancel();
    return super.close();
  }
}
