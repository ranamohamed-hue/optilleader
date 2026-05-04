import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:optialeader/feature/auth/data/models/user_model.dart';
import 'auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepoImpl({required this.auth, required this.firestore});

  // LOGIN
  @override
  Future<Either<String, UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = credential.user;
      if (user == null) {
        return const Left("فشل تسجيل الدخول");
      }

      final doc = await firestore.collection('users').doc(user.uid).get();

      if (!doc.exists) {
        return const Left("بيانات المستخدم غير موجودة");
      }

      final userModel = UserModel.fromFirestore(doc);

      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      return Left(e.message ?? "فشل تسجيل الدخول");
    } catch (e) {
      return const Left("حدث خطأ أثناء تسجيل الدخول");
    }
  }

  // SIGN UP
  @override
  Future<Either<String, UserModel>> signUp({
    required UserModel userModel,
    required String password,
  }) async {
    try {
      // 1. إنشاء الحساب في Firebase Authentication
      final credential = await auth.createUserWithEmailAndPassword(
        email: userModel.universityEmail.trim(),
        password: password.trim(),
      );
      final uid = credential.user!.uid;

      // 2. البحث عن الدوكيمنت القديم (صاحب الـ ID العشوائي)
      final preExistingDoc = await firestore
          .collection('users')
          .where('employee_id', isEqualTo: userModel.employeeId)
          .get();

      // 3. حذف الدوكيمنت القديم لو موجود
      if (preExistingDoc.docs.isNotEmpty) {
        for (var doc in preExistingDoc.docs) {
          await firestore.collection('users').doc(doc.id).delete();
        }
      }

      await firestore
          .collection('users')
          .doc(uid)
          .set(userModel.copyWith(uid: uid, isRegistered: true).toMap());

      return Right(userModel.copyWith(uid: uid, isRegistered: true));
    } on FirebaseAuthException catch (e) {
      return Left(e.message ?? "فشل إنشاء الحساب");
    } catch (e) {
      return const Left("حدث خطأ أثناء التسجيل");
    }
  }

  // FIRST LOGIN
  @override
  Future<Either<String, String>> completeFirstLogin({
    required String newPassword,
  }) async {
    try {
      final user = auth.currentUser;

      if (user == null) {
        return const Left("المستخدم غير مسجل الدخول");
      }

      await user.updatePassword(newPassword.trim());

      await firestore.collection('users').doc(user.uid).update({
        'isFirstLogin': false,
      });

      return const Right("تم تحديث كلمة المرور بنجاح");
    } catch (e) {
      return const Left("فشل تحديث كلمة المرور");
    }
  }

  // RESET PASSWORD
  @override
  Future<Either<String, String>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await auth.sendPasswordResetEmail(email: email.trim());
      return const Right("تم إرسال رابط إعادة التعيين");
    } catch (e) {
      return const Left("فشل إرسال الإيميل");
    }
  }

  // LOGOUT
  @override
  Future<Either<String, void>> logout() async {
    try {
      await auth.signOut();
      return const Right(null);
    } catch (e) {
      return const Left("فشل تسجيل الخروج");
    }
  }

  // VERIFY USER (لو محتاجه)
  @override
  Future<Either<String, UserModel>> verifyUser({
    required String email,
    required String nationalId,
    required String employeeId,
  }) async {
    try {
      final query = await firestore
          .collection('users')
          .where('university_email', isEqualTo: email.trim())
          .where('national_id', isEqualTo: nationalId.trim())
          .where('employee_id', isEqualTo: employeeId.trim())
          .get();

      if (query.docs.isEmpty) {
        return const Left("البيانات غير صحيحة");
      }

      final user = UserModel.fromFirestore(query.docs.first);

      if (user.isRegistered) {
        return const Left("تم التسجيل مسبقاً، قم بتسجيل الدخول");
      }

      return Right(user);
    } catch (e) {
      return const Left("خطأ أثناء التحقق");
    }
  }
}
