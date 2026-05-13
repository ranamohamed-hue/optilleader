import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/database_admin/data/repo/doctor_repository/doctor_repo.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_state.dart';
import 'package:optialeader/firebase_options.dart'; // ✅ [مهم جداً] يجب إضافة هذا الاستيراد ليعمل DefaultFirebaseOptions

class DoctorDataCubit extends Cubit<DoctorDataState> {
  final DoctorRepo doctorRepo;
  StreamSubscription? _doctorsSubscription;

  DoctorDataCubit(this.doctorRepo) : super(DoctorInitial());

  // جلب بيانات دكتور معين
  Future<void> getDoctorProfile(String uid) async {
    emit(DoctorLoading());
    final result = await doctorRepo.getDoctorProfile(uid);
    result.fold(
      (error) => emit(DoctorError(error: error)),
      (doctor) => emit(DoctorLoaded(doctor: doctor)),
    );
  }

  // حفظ بيانات دكتور بالكامل
  Future<void> saveDoctorData(DoctorProfileModel doctor) async {
    emit(DoctorLoading());
    final result = await doctorRepo.saveDoctorData(doctor);
    result.fold(
      (error) => emit(DoctorError(error: error)),
      (_) => emit(DoctorSuccess()),
    );
  }

  // تحديث حالة الحساب
  Future<void> updateAccountStatus(String uid, bool isActive) async {
    emit(DoctorLoading());
    final result = await doctorRepo.updateAccountStatus(uid, isActive);
    result.fold(
      (error) => emit(DoctorError(error: error)),
      (_) => emit(DoctorSuccess()),
    );
  }

  // مراقبة قائمة الدكاترة
  void watchAllDoctors() {
    emit(DoctorLoading());
    _doctorsSubscription?.cancel();
    _doctorsSubscription = doctorRepo.watchAllDoctors().listen(
      (doctorsList) {
        emit(AllDoctorLoaded(doctors: doctorsList));
      },
      onError: (error) {
        emit(DoctorError(error: error.toString()));
      },
    );
  }

  /// 🟢 إنشاء دكتور جديد (Auth + Firestore)
  Future<void> createNewDoctor(DoctorProfileModel doctor) async {
    emit(DoctorLoading());
    UserCredential? credential;

    try {
      // ✅ [الحل الجذري] التحقق من وجود النسخة الثانوية وإنشاؤها إذا لم تكن موجودة
      FirebaseApp secondaryApp;
      final isSecondaryAppInitialized = Firebase.apps.any((app) => app.name == 'SecondaryApp');
      
      if (isSecondaryAppInitialized) {
        secondaryApp = Firebase.app('SecondaryApp');
      } else {
        secondaryApp = await Firebase.initializeApp(
          name: 'SecondaryApp',
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      // 2. إنشاء الحساب (الإيميل + الرقم القومي كباصورد)
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: doctor.email.trim(),
        password: doctor.nationalId.trim(),
      );

      // ✅ 3. استخراج الـ user والتأكد من أنه ليس null بأمان
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        emit(DoctorError(error: "ERROR_USER_CREATION_FAILED"));
        return;
      }

      // 4. أخذ الـ UID بأمان
      final String newUid = firebaseUser.uid;

      // 5. تحديث الموديل بالـ UID
      final updatedDoctor = doctor.copyWith(uid: newUid);

      // 6. حفظ البيانات في الفايرستور
      final result = await doctorRepo.saveDoctorData(updatedDoctor);

      // 7. معالجة النتيجة
      result.fold((error) async {
        // ❌ فشل الحفظ في الفايرستور -> ✅ حذف الحساب من الـ Auth لمنع الحساب اليتيم
        try {
          await firebaseUser.delete();
        } catch (_) {}
        emit(DoctorError(error: error));
      }, (_) => emit(DoctorSuccess()));
      
    } on FirebaseAuthException catch (e) {
      // ✅ إرسال كود الخطأ بدلاً من النص العربي
      String errorCode = "ERROR_AUTH_UNKNOWN";
      if (e.code == 'email-already-in-use') {
        errorCode = "ERROR_EMAIL_ALREADY_IN_USE";
      } else if (e.code == 'weak-password') {
        errorCode = "ERROR_WEAK_PASSWORD";
      } else if (e.code == 'invalid-email') {
        errorCode = "ERROR_INVALID_EMAIL";
      }
      emit(DoctorError(error: errorCode));
    } catch (e) {
      // في حال فشل أي شيء آخر، نحاول حذف الحساب إذا تم إنشاؤه
      try {
        await credential?.user?.delete();
      } catch (_) {}
      emit(DoctorError(error: e.toString()));
    } finally {
      // ✅ تسجيل الخروج من النسخة الثانوية بأمان في جميع الحالات
      try {
        final secondaryApp = Firebase.app('SecondaryApp');
        final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
        await secondaryAuth.signOut();
      } catch (_) {}
    }
  }

  // حذف حساب دكتور
  Future<void> deleteDoctor(String uid) async {
    emit(DoctorDeleting());
    final result = await doctorRepo.deleteDoctorAccount(uid);
    result.fold(
      (error) => emit(DoctorError(error: error)),
      (_) => emit(DoctorSuccess()),
    );
  }

  // اغلاق stream
  @override
  Future<void> close() {
    _doctorsSubscription?.cancel();
    return super.close();
  }
}