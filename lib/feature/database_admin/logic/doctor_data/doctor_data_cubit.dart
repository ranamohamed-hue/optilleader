import 'dart:async';
import 'dart:io';
import 'dart:typed_data'; // ✅ [إضافة]
import 'package:path/path.dart' as p;
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ [إضافة مهمة] عشان FieldValue.arrayUnion
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/database_admin/data/repo/doctor_repository/doctor_repo.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_state.dart';
import 'package:optialeader/firebase_options.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart'; // ✅ [إضافة]

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

  // حفظ بيانات دكتور بالكامل (للأدمن)
  Future<void> saveDoctorData(DoctorProfileModel doctor) async {
    emit(DoctorLoading());
    final result = await doctorRepo.saveDoctorData(doctor);
    result.fold(
      (error) => emit(DoctorError(error: error)),
      (_) => emit(DoctorSuccess()),
    );
  }

  // ✅ تحديث بيانات الدكتور (لما الدكتور يكمل بروفايله)
  Future<void> updateDoctorProfile(
    String uid,
    Map<String, dynamic> updatedFields,
  ) async {
    final result = await doctorRepo.updateDoctorProfileData(uid, updatedFields);
    result.fold((error) => emit(DoctorError(error: error)), (_) {
      getDoctorProfile(uid);
    });
  }

  // ✅ رفع صورة وتحديث البروفايل (بتضغط الصورة)
  Future<void> uploadAndSetProfileImage(String uid, File imageFile) async {
    emit(DoctorLoading()); 

    try {
      final Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        minWidth: 1024,
        minHeight: 1024,
        quality: 85, 
      );

      if (compressedBytes == null) {
        emit(DoctorError(error: "فشل ضغط الصورة"));
        return;
      }

      final String fileExtension = p.extension(imageFile.path);
      final String storagePath = 'profiles/$uid/profile$fileExtension';

      final uploadResult = await doctorRepo.uploadFile(
        compressedBytes, 
        storagePath,
        bucketName: 'images',
      );

      uploadResult.fold((error) => emit(DoctorError(error: error)), (
        imageUrl,
      ) async {
        final updateResult = await doctorRepo.updateDoctorImage(uid, imageUrl);
        updateResult.fold((error) => emit(DoctorError(error: error)), (_) {
          getDoctorProfile(uid);
        });
      });
    } catch (e) {
      emit(DoctorError(error: e.toString()));
    }
  }

  // ✅✅✅ [إضافة جديدة] دالة رفع ملفات للأرشيف (بتخزن Array في الفايرستور)
  Future<void> uploadArchiveFile({
    required String uid,
    required File file,
    required String title,
    required String description,
    required String category,
  }) async {
    emit(DoctorLoading()); 

    try {
      // 1. قراءة الملف كـ Bytes
      final fileBytes = await file.readAsBytes();
      final String fileExtension = p.extension(file.path); 
      
      // 2. بناء المسار داخل البوكت
      final String storagePath = 'archives/$uid/${DateTime.now().millisecondsSinceEpoch}$fileExtension';

      // 3. رفع الملف على بوكت الـ files في السوبابيز
      final uploadResult = await doctorRepo.uploadFile(
        fileBytes,
        storagePath,
        bucketName: 'files',
      );

      uploadResult.fold(
        (error) => emit(DoctorError(error: error)), 
        (fileUrl) async {
          // 4. تجهيز الـ Object اللي هيتحفظ في الفايرستور
          final newFileData = {
            'title': title,
            'description': description,
            'category': category,
            'file_url': fileUrl,
            'uploaded_at': FieldValue.serverTimestamp(), 
          };

          // 5. تحديث الفايرستور بإضافة الملف للستة (arrayUnion)
          final updateResult = await doctorRepo.updateDoctorProfileData(uid, {
            'digital_archive': FieldValue.arrayUnion([newFileData]),
          });
          
          updateResult.fold(
            (error) => emit(DoctorError(error: error)), 
            (_) => getDoctorProfile(uid), 
          );
        },
      );
    } catch (e) {
      emit(DoctorError(error: e.toString()));
    }
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

  /// إنشاء دكتور جديد (Auth + Firestore)
  Future<void> createNewDoctor(DoctorProfileModel doctor) async {
    emit(DoctorLoading());
    UserCredential? credential;

    try {
      FirebaseApp secondaryApp;
      final isSecondaryAppInitialized = Firebase.apps.any(
        (app) => app.name == 'SecondaryApp',
      );

      if (isSecondaryAppInitialized) {
        secondaryApp = Firebase.app('SecondaryApp');
      } else {
        secondaryApp = await Firebase.initializeApp(
          name: 'SecondaryApp',
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: doctor.email.trim(),
        password: doctor.nationalId.trim(),
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        emit(DoctorError(error: "ERROR_USER_CREATION_FAILED"));
        return;
      }

      final String newUid = firebaseUser.uid;
      final updatedDoctor = doctor.copyWith(uid: newUid);
      final result = await doctorRepo.saveDoctorData(updatedDoctor);

      result.fold((error) async {
        try {
          await firebaseUser.delete();
        } catch (_) {}
        emit(DoctorError(error: error));
      }, (_) => emit(DoctorSuccess()));
    } on FirebaseAuthException catch (e) {
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
      try {
        await credential?.user?.delete();
      } catch (_) {}
      emit(DoctorError(error: e.toString()));
    } finally {
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