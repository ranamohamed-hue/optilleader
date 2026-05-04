import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/database_admin/data/repo/database_admin_repository/database_admin_repo.dart';
import 'package:optialeader/feature/database_admin/logic/database_admin_data/database_admin_state.dart';

class DatabseAdminCubit extends Cubit<DatabaseAdminState> {
  final DatabaseAdminRepo _databaseAdminRepo;
  DatabseAdminCubit(this._databaseAdminRepo) : super(DatabaseAdminInitial());
  Future<void> getProfile(String uid) async {
    emit(DatabaseAdminLoading());

    final result = await _databaseAdminRepo.getAdminProfile(uid);

    result.fold(
      (error) => emit(DatabaseAdminError(error)),
      (profile) => emit(DatabaseAdminSuccess(profile)),
    );
  }
  Future<void> updateInfo({
    required String uid,
    required String phone,
    required String addrAr,
    required String addrEn,
  }) async {
   emit(DatabaseAdminLoading());
   final result=await _databaseAdminRepo.updateAdminInfo(uid: uid, newPhone: phone, addressAr: addrAr, addressEn: addrEn) ;
   result.fold(
      (error) => emit(DatabaseAdminError(error)),
      (_) {
        emit(DatabaseAdminUpdateSuccess());
        getProfile(uid); 
      },
    );
  }
  Future<void> updateImage({
    required String uid,
    required String imageUrl,
  }) async {
    emit(DatabaseAdminLoading());
    final result = await _databaseAdminRepo.updateProfileImage(uid, imageUrl);

    result.fold(
      (error) => emit(DatabaseAdminError(error)),
      (_) {
        emit(DatabaseAdminUpdateSuccess());
        getProfile(uid); 
      },
    );
  }
}
