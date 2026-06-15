import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_state.dart';
import 'package:optialeader/feature/database_admin/logic/leadership_scoring_engine/leadership_scoring_engine.dart';
import 'package:optialeader/feature/database_admin/logic/leadership_scoring_engine/leadership_state.dart';

class LeadershipCubit extends Cubit<LeadershipState> {
  final DoctorDataCubit doctorDataCubit;

  LeadershipCubit({required this.doctorDataCubit}) : super(LeadershipInitial());

  // 1. حساب نقاط الدورات
  void calculateLeadershipScore() {
    emit(LeadershipLoading());
    final doctorState = doctorDataCubit.state;

    if (doctorState is DoctorLoaded) {
      final DoctorProfileModel doctor = doctorState.doctor!;
      final int coursePoints = LeadershipScoringEngine.calculateCoursePoints(doctor.activities);
      emit(LeadershipScoreLoaded(coursePoints: coursePoints));
    } else {
      emit(LeadershipError("بيانات الدكتور غير متاحة"));
    }
  }

  // 2. حساب نسب مادة 22
  void calculateArticle22Percentages() {
    emit(LeadershipLoading());
    final doctorState = doctorDataCubit.state;

    if (doctorState is DoctorLoaded) {
      final DoctorProfileModel doctor = doctorState.doctor!;
      Map<String, double> participationMap = {};

      for (var paper in doctor.researchPapers) {
        double percentage = LeadershipScoringEngine.calculateParticipationPercentage(
          authorOrder: paper.authorOrder,
          authorsInSameSpecialty: paper.authorsInSameSpecialty,
          isTopTierJournal: paper.isTopTierJournal,
        );
        participationMap[paper.id] = percentage;
      }

      // ✅ بعتنا الـ Map للـ UI
      emit(Article22Loaded(participationMap: participationMap));
    } else {
      emit(LeadershipError("بيانات الدكتور غير متاحة"));
    }
  }

  // 3. التحقق من الشروط الإجبارية
  void checkMandatoryCriteria({required String targetRole}) {
    emit(LeadershipLoading());
    final doctorState = doctorDataCubit.state;

    if (doctorState is DoctorLoaded) {
      final DoctorProfileModel doctor = doctorState.doctor!;
      
      // ✅ شغلنا محرك الشروط من الـ Engine
      final criteria = LeadershipScoringEngine.checkMandatoryCriteria(
        doctor: doctor, 
        targetRole: targetRole
      );

      // ✅ بعتهاللـ UI عشان يرسم الـ ✅ و ❌
      emit(MandatoryCriteriaLoaded(criteria: criteria));
    } else {
      emit(LeadershipError("بيانات الدكتور غير متاحة"));
    }
  }
 
  void loadNominationData({required String targetRole}) {
    emit(LeadershipLoading());
    final doctorState = doctorDataCubit.state;

    if (doctorState is DoctorLoaded) {
      final DoctorProfileModel doctor = doctorState.doctor!;

      // 1. حساب الدرجات الآلية (الدورات وغيرها)
      final scores = LeadershipScoringEngine.calculateTotalScore(doctor);

      // 2. التحقق من الشروط الإجبارية
      final criteria = LeadershipScoringEngine.checkMandatoryCriteria(
        doctor: doctor,
        targetRole: targetRole,
      );

      // 3. إرسال البيانات مجتمعة للـ UI
      emit(NominationDataLoaded(scores: scores, criteria: criteria));
    } else {
      emit(LeadershipError("error_fetch_requests")); // ✅ Key للترجمة
    }
  }

}