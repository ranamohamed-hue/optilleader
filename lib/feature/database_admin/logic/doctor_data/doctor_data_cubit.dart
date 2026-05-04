import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/database_admin/data/repo/doctor_repository/doctor_repo.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_state.dart';

class DoctorDataCubit extends Cubit<DoctorDataState> {
  final DoctorRepo doctorRepo;
  //عشان نقفل قناة الاتصال
  StreamSubscription? _doctorsSubscription;
  DoctorDataCubit(this.doctorRepo) : super(DoctorInitial());
  //حفظ او تحديث بيانات دكتور بالكامل
  Future<void> getDoctorProfile(String uid) async {
    emit(DoctorLoading());
    final result = await doctorRepo.getDoctorProfile(uid);
    result.fold(
      (error) => emit(DoctorError(error: error)),
      (doctor) => emit(DoctorLoaded(doctor: doctor)),
    );
  }

  //حفظ  بيانات دكتور بالكامل
  Future<void> saveDoctorData(DoctorProfileModel doctor) async {
    emit(DoctorLoading());
    final resut = await doctorRepo.saveDoctorData(doctor);
    resut.fold(
      (error) => emit(DoctorError(error: error)),
      (_) => emit(DoctorSuccess()),
    );
  }

  //تحديث  حالة الحساب 
  Future<void> updateAccountStatus(String uid, bool isActive) async {
    emit(DoctorLoading());
    final result = await doctorRepo.updateAccountStatus(uid, isActive);
    result.fold(
      (error) => emit(DoctorError(error: error)),
      (_) => emit(DoctorSuccess()),
    );
  }

  // مراقبة قائمة الدكاترة عشان اي تحديثات تتعمل تظهر عنده
  void watchAllDoctors() {
    emit(DoctorLoading());
    _doctorsSubscription?.cancel(); //عشان اقفل اي قناه اتصال قديم مفتوحه
    _doctorsSubscription = doctorRepo.watchAllDoctors().listen(
      (doctorsList) {
        emit(AllDoctorLoaded(doctors: doctorsList));
      },
      onError: (error) {
        emit(DoctorError(error: error.toString()));
      },
    );
  }

  //حذف حساب دكتور
  Future<void> deleteDoctor(String uid) async {
    emit(DoctorDeleting());
    final result = await doctorRepo.deleteDoctorAccount(uid);
    result.fold(
      (error) => emit(DoctorError(error: error)),
      (_) => emit(DoctorSuccess()),
    );
  }
  //اغلاق stream
  @override
  Future<void> close(){
    _doctorsSubscription?.cancel();
    return super.close();
  }
}
