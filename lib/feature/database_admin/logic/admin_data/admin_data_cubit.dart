import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:optialeader/feature/database_admin/data/models/admin_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/admin_data/admin_data_state.dart';
import 'package:optialeader/feature/database_admin/data/repo/admin_repository/admin_repo.dart';

class AdminDataCubit extends Cubit<AdminDataState> {
  final AdminRepo adminRepo;
  StreamSubscription? _adminsSubscription;
  AdminDataCubit(this.adminRepo) : super(AdminInitial());
  //لجلب بيانات ادمن معين
  Future<void> getAdminProfile(String uid) async {
    emit(AdminLoading());
    final result = await adminRepo.getAdminProfile(uid);
    result.fold(
      (error) => emit(AdminError(error: error)),
      (admin) => emit(AdminLoaded(admin: admin)),
    );
  }

  //حفظ وتحديث بيانات الادمن
  Future<void> saveAdminData(AdminProfileModel admin) async {
    emit(AdminLoading());
    final result = await adminRepo.saveAdminData(admin);
    result.fold(
      (error) => emit(AdminError(error: error)),
      (_) => emit(AdminSuccess()),
    );
  }

  //مرقبه كل تحديثات الادمن
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

  @override
  Future<void> close() {
    _adminsSubscription?.cancel();
    return super.close();
  }
  Future<void> updateAccountStatus(String uid, bool isActive) async {
    final result = await adminRepo.updateAccountStatus(uid, isActive);
    result.fold(
      (error) => emit(AdminError(error: error)),
      (_) => emit(AdminSuccess()), 
    );
  }
}
