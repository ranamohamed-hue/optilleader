import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bloc/bloc.dart';
import 'package:optialeader/feature/database_admin/data/models/admin_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/admin_data/admin_data_state.dart';
import 'package:optialeader/feature/database_admin/data/repo/admin_repository/admin_repo.dart';
import 'package:optialeader/firebase_options.dart'; // ✅ [مهم جداً] يجب إضافة هذا الاستيراد ليعمل DefaultFirebaseOptions

class AdminDataCubit extends Cubit<AdminDataState> {
  final AdminRepo adminRepo;
  StreamSubscription? _adminsSubscription;

  AdminDataCubit(this.adminRepo) : super(AdminInitial());

  // جلب بيانات أدمن معين
  // جلب بيانات أدمن معين
  Future<void> getAdminProfile(String uid) async {
    emit(AdminLoading());
    final result = await adminRepo.getAdminProfile(uid);
    
    result.fold(
      (error) => emit(AdminError(error: error)),
      (admin) async {
        // ✅ بعد ما نجحنا في جلب البروفايل، نجلب العدادات
        final counts = await adminRepo.getAdminDashboardCounts();
        
        // ✅ نemit حالة النجاح بالبروفايل والعدادات
        emit(AdminLoaded(
          admin: admin,
          newRequestsCount: counts['newRequests'] ?? 0,
          underReviewCount: counts['underReview'] ?? 0,
        ));
      },
    );
  }

  // حفظ وتحديث بيانات الادمن
  Future<void> saveAdminData(AdminProfileModel admin) async {
    emit(AdminLoading());
    final result = await adminRepo.saveAdminData(admin);
    result.fold(
      (error) => emit(AdminError(error: error)),
      (_) => emit(AdminSuccess()),
    );
  }

  /// إنشاء أدمن جديد (Auth + Firestore)
   Future<void> createNewAdmin(AdminProfileModel admin) async {
    emit(AdminLoading());
    UserCredential? credential;

    try {
      // 1. تهيئة النسخة الثانوية بأمان
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

      // 2. إنشاء الحساب
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: admin.email.trim(),
        password: admin.nationalId.trim(),
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        emit(AdminError(error: "ERROR_USER_CREATION_FAILED"));
        return;
      }

      final String newUid = firebaseUser.uid;
      final updatedAdmin = admin.copyWith(uid: newUid);

      // ✅ 3. [تعديل مهم] لف عملية الحفظ في try-catch منفصل لضمان عدم التهنيج
      try {
        final result = await adminRepo.saveAdminData(updatedAdmin);
        result.fold(
          (error) async {
            try { await firebaseUser.delete(); } catch (_) {}
            emit(AdminError(error: error));
          }, 
          (_) => emit(AdminSuccess()),
        );
      } catch (e) {
        // في حال رمى الـ Repository خطأ غير متوقع
        try { await firebaseUser.delete(); } catch (_) {}
        emit(AdminError(error: e.toString()));
      }

    } on FirebaseAuthException catch (e) {
      String errorCode = "ERROR_AUTH_UNKNOWN";
      if (e.code == 'email-already-in-use') errorCode = "ERROR_EMAIL_ALREADY_IN_USE";
      if (e.code == 'weak-password') errorCode = "ERROR_WEAK_PASSWORD";
      emit(AdminError(error: errorCode));
    } catch (e) {
      emit(AdminError(error: e.toString()));
    } finally {
      try {
        final secondaryApp = Firebase.app('SecondaryApp');
        final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
        await secondaryAuth.signOut();
      } catch (_) {}
    }
  }

  // مراقبة كل تحديثات الادمن
  void watchAllAdmins() {
    emit(AdminLoading());
    _adminsSubscription?.cancel();
    _adminsSubscription = adminRepo.watchAllAdmins().listen(
      (adminsList) {
        emit(AllAdminsLoaded(admins: adminsList));
      },
      onError: (error) {
        emit(AdminError(error: error.toString()));
      },
    );
  }

  Future<void> deleteAdmin(String uid) async {
    emit(AdminDeleting());
    final result = await adminRepo.deleteAdminAccount(uid);
    result.fold(
      (error) => emit(AdminError(error: error)),
      (_) => emit(AdminSuccess()),
    );
  }

  Future<void> updateAccountStatus(String uid, bool isActive) async {
    final result = await adminRepo.updateAccountStatus(uid, isActive);
    result.fold(
      (error) => emit(AdminError(error: error)),
      (_) => emit(AdminSuccess()),
    );
  }

  @override
  Future<void> close() {
    _adminsSubscription?.cancel();
    return super.close();
  }
}