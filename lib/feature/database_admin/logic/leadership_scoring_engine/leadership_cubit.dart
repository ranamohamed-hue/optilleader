import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_state.dart';
import 'package:optialeader/feature/database_admin/logic/leadership_scoring_engine/leadership_scoring_engine.dart';
import 'package:optialeader/feature/database_admin/logic/leadership_scoring_engine/leadership_criteria_engine.dart';
import 'package:optialeader/feature/database_admin/logic/leadership_scoring_engine/leadership_state.dart';

class LeadershipCubit extends Cubit<LeadershipState> {
  final DoctorDataCubit doctorDataCubit;

  LeadershipCubit({required this.doctorDataCubit}) : super(LeadershipInitial());

  // 1. حساب نقاط الدورات (من الموديل الجديد)
  void calculateLeadershipScore() {
    emit(LeadershipLoading());
    final doctorState = doctorDataCubit.state;

    if (doctorState is DoctorLoaded) {
      final DoctorProfileModel doctor = doctorState.doctor!;
      
      double totalCoursePoints = 0.0;
      for (var course in doctor.courses) {
        if (course.status.name == 'approved' && !course.isMandatory) {
          totalCoursePoints += course.points;
        }
      }
      
      emit(LeadershipScoreLoaded(coursePoints: totalCoursePoints));
    } else {
      emit(LeadershipError("بيانات الدكتور غير متاحة"));
    }
  }

  // 2. حساب نسب مادة 22 (من الموديل الجديد)
  void calculateArticle22Percentages() {
    emit(LeadershipLoading());
    final doctorState = doctorDataCubit.state;

    if (doctorState is DoctorLoaded) {
      final DoctorProfileModel doctor = doctorState.doctor!;
      Map<String, double> participationMap = {};

      for (var paper in doctor.researchPapers) {
        participationMap[paper.id] = paper.participationPercentage;
      }

      emit(Article22Loaded(participationMap: participationMap));
    } else {
      emit(LeadershipError("بيانات الدكتور غير متاحة"));
    }
  }

  // ✅ 3. التحقق من الشروط الإجبارية (تم تحديثه ليكون آسync ويجلب الدكاترة)
  Future<void> checkMandatoryCriteria({required String targetRole}) async {
    emit(LeadershipLoading());
    final doctorState = doctorDataCubit.state;

    if (doctorState is DoctorLoaded) {
      final DoctorProfileModel doctor = doctorState.doctor!;
      
      // ✅ جلب الدكاترة ديناميكياً لو كان الشرط يتطلب ذلك (مثل أقدم 3)
      List<DoctorProfileModel> departmentDoctors = [];
      if (targetRole == 'head_department') {
        try {
          departmentDoctors = await doctorDataCubit.getAllDoctorsOnce();
        } catch (_) {}
      }
      
      // ✅ تمرير الدكاترة للمحرك
      final criteria = LeadershipCriteriaEngine.checkMandatoryCriteria(
        doctor: doctor, 
        targetRole: targetRole,
        departmentDoctors: departmentDoctors, // ✅ تمت الإضافة
      );

      emit(MandatoryCriteriaLoaded(criteria: criteria));
    } else {
      emit(LeadershipError("بيانات الدكتور غير متاحة"));
    }
  }
 
  // ✅ 4. تجميع البيانات لصفحة التقديم (تم تحديثه ليكون آسync ويجلب الدكاترة)
  Future<void> loadNominationData({required String targetRole}) async {
    emit(LeadershipLoading());
    final doctorState = doctorDataCubit.state;

    if (doctorState is DoctorLoaded) {
      final DoctorProfileModel doctor = doctorState.doctor!;

      // ✅ جلب الدكاترة ديناميكياً لو كان الشرط يتطلب ذلك
      List<DoctorProfileModel> departmentDoctors = [];
      if (targetRole == 'head_department') {
        try {
          departmentDoctors = await doctorDataCubit.getAllDoctorsOnce();
        } catch (_) {}
      }

      // 1. حساب الدرجات الآلية
      final scores = LeadershipScoringEngine.calculateTotalScore(doctor);

      // 2. التحقق من الشروط الإجبارية (بتمرير الدكاترة)
      final criteria = LeadershipCriteriaEngine.checkMandatoryCriteria(
        doctor: doctor,
        targetRole: targetRole,
        departmentDoctors: departmentDoctors,
      );

      // 3. إرسال البيانات مجتمعة للـ UI
      emit(NominationDataLoaded(scores: scores, criteria: criteria));
    } else {
      emit(LeadershipError("error_fetch_requests"));
    }
  }
}