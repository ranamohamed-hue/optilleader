import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/auth/data/models/user_model.dart';

abstract class AuthRepo {
  Future<Either<String, UserModel>> login({
    required String email,
    required String password,
  });

  Future<Either<String, UserModel>> signUp({
    required UserModel userModel,
    required String password,
  });

  Future<Either<String, UserModel>> verifyUser({
    required String email,
    required String nationalId,
    required String employeeId,
  });

  Future<Either<String, String>> sendPasswordResetEmail({
    required String email,
  });

  Future<Either<String, String>> completeFirstLogin({
  required String newPassword,
});
  Future<Either<String, void>> logout();
}