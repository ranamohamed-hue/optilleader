import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/doctor/data/model/activities_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';

abstract class ActivityRepo {
  Future<Either<String, Unit>> addActivity({
    required String doctorUid,
    required ActivityModel activity,
    File? proofFile,
  });

  Future<Either<String, Unit>> deleteActivity(
    String doctorUid,
    String activityId,
  );

  Future<Either<String, Unit>> updateActivityStatus(
    String doctorUid,
    String activityId,
    VerificationStatus status, {
    String? rejectionReason,
  });
}