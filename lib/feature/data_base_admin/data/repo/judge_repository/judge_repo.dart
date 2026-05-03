import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/data_base_admin/data/models/judge_profile_model.dart';

abstract class JudgeRepo {
  Future<Either<String, Unit>> saveJudgeData(JudgeProfileModel judge);

  Future<Either<String, JudgeProfileModel?>> getJudgeProfile(String uid);
  // مراقبة كل الحكام في الوقت الفعلي
  Stream<List<JudgeProfileModel>> watchAllJudges();

  Future<Either<String, Unit>> updateJudgeStatus(String uid, bool isActive);

  Future<Either<String, Unit>> updateJudgeImage(String uid, String imageUrl);

  Future<Either<String, Unit>> deleteJudgeAccount(String uid);
}
