import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/admin/data/repo/admin_repo.dart';
import 'package:optialeader/feature/admin/logic/admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminRepo adminRepo;

  AdminCubit(this.adminRepo) : super(AdminInitial());

  /// ================= 🟢 GET PROFILE =================
  Future<void> getAdminProfile(String uid) async {
    emit(AdminLoading());

    final result = await adminRepo.getAdminProfile(uid);

    result.fold(
      (error) => emit(AdminError(error)),
      (admin) => emit(AdminSuccess(admin)), // إرسال البيانات مباشرة بعد الحصول عليها
    );
  }

  /// ================= 🟢 UPDATE =================
  Future<void> updateAdminData({
    required String uid,
    String? imageUrl,
    String? address,
    String? phone1,
    String? phone2,
  }) async {
    emit(AdminLoading()); // قبل التحديث نعرض حالة التحميل

    final result = await adminRepo.updateAdminProfile(
      uid: uid,
      imageUrl: imageUrl,
      address: address,
      phone1: phone1,
      phone2: phone2,
    );

    result.fold(
      (error) => emit(AdminError(error)), // في حالة حدوث خطأ
      (_) async {
        /// ✅ نجيب البيانات الجديدة بعد التحديث
        final profileResult = await adminRepo.getAdminProfile(uid);

        profileResult.fold(
          (error) => emit(AdminError(error)), // إذا حدث خطأ عند جلب البيانات
          (admin) {
            // ✅ بعد التحديث نعرض البيانات الجديدة مع رسالة التحديث
            emit(AdminSuccess(admin, message: "تم التحديث بنجاح"));
          },
        );
      },
    );
  }
}