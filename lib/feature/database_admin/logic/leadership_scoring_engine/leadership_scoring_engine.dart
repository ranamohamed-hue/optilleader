import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/doctor/data/model/academic_activity_model.dart';
import 'package:optialeader/feature/judge/data/model/interview_scoring_model.dart';
import 'package:optialeader/feature/doctor/data/model/conferance_model.dart';
import 'package:optialeader/feature/doctor/data/model/exhibition_venue_model.dart';
import 'package:optialeader/feature/doctor/data/model/courses_model.dart';
import 'package:optialeader/feature/admin/data/model/nomination_score_model.dart';
class LeadershipScoringEngine {

  /// ✅ حساب إجمالي درجات الإنجازات
  static Map<String, dynamic> calculateTotalScore(DoctorProfileModel doctor) {
    List<Map<String, dynamic>> allDetails = [];
    double researchPoints = 0.0;
    double conferencePoints = 0.0;
    double exhibitionPoints = 0.0;
    double coursePoints = 0.0;
    double activityPoints = 0.0;

    // 1️⃣ الأبحاث العلمية
    for (var paper in doctor.researchPapers) {
      if (paper.status.name == 'approved') {
        researchPoints += paper.finalPoints;
        allDetails.add({
          'title': paper.titleAr,
          'type': 'بحث علمي',
          'category': paper.isLocalJournal ? 'مجلة محلية' : 'مجلة دولية',
          'scope': 'نسبة المشاركة: ${(paper.participationPercentage * 100).toInt()}%',
          'points': paper.finalPoints,
          'breakdown': '(إدارة: ${paper.adminScore} + مجلة: ${paper.journalPoints}) × ${paper.participationPercentage}',
        });
      }
    }

    // 2️⃣ المؤتمرات
    for (var conf in doctor.conferences) {
      if (conf.status.name == 'approved') {
        conferencePoints += conf.totalPoints;
        allDetails.add({
          'title': conf.title,
          'type': conf.isInternational ? 'مؤتمر دولي' : 'مؤتمر محلي',
          'category': _getParticipationTypeAr(conf.participationType),
          'scope': conf.isSpecialized ? 'متخصص' : 'غير متخصص',
          'points': conf.totalPoints,
        });
      }
    }

    // 3️⃣ المعارض الفنية
    for (var exhibition in doctor.exhibitions) {
      if (exhibition.status.name == 'approved') {
        if (exhibition.isExceptionalCase) {
          allDetails.add({
            'title': exhibition.title,
            'type': 'معرض فني (بحث معلق)',
            'category': 'دولي',
            'scope': 'يحتاج تقييم كبحث',
            'points': 0.0,
          });
        } else {
          exhibitionPoints += exhibition.basePoints;
          allDetails.add({
            'title': exhibition.title,
            'type': 'معرض فني',
            'category': _getVenueAr(exhibition.venue),
            'scope': '${exhibition.numberOfWorks} أعمال',
            'points': exhibition.basePoints,
          });
        }
      }
    }

    // 4️⃣ الدورات التدريبية (اللي عليها درجات)
    for (var course in doctor.courses) {
      if (course.status.name == 'approved' && !course.isMandatory) {
        coursePoints += course.points;
        allDetails.add({
          'title': course.title,
          'type': 'دورة تدريبية',
          'category': _getCourseCategoryAr(course.courseCategory),
          'scope': _getCourseScopeAr(course.courseScope),
          'points': course.points,
        });
      }
    }

    // 5️⃣ الأنشطة الأكاديمية (الـ 20 درجة)
    if (doctor.academicActivities != null) {
      activityPoints = doctor.academicActivities!.totalPoints;
      _addActivityDetails(doctor.academicActivities!, allDetails);
    }

    double totalPoints = researchPoints + conferencePoints + 
                         exhibitionPoints + coursePoints + activityPoints;

    return {
      'researchPoints': researchPoints,
      'conferencePoints': conferencePoints,
      'exhibitionPoints': exhibitionPoints,
      'coursePoints': coursePoints,
      'activityPoints': activityPoints,
      'totalPoints': totalPoints,
      'evaluated_items_details': allDetails,
    };
  }

  // ============================================================
  // 🎯 بناء موديل الدرجات من بيانات الدكتور
  // ============================================================
  static NominationScoreModel buildScoreModel(DoctorProfileModel doctor) {
    Map<String, dynamic> scores = calculateTotalScore(doctor);
    
    return NominationScoreModel(
      researchPoints: scores['researchPoints'],
      conferencePoints: scores['conferencePoints'],
      exhibitionPoints: scores['exhibitionPoints'],
      coursePoints: scores['coursePoints'],
      activityPoints: scores['activityPoints'],
      itemsDetails: List<Map<String, dynamic>>.from(scores['evaluated_items_details']),
    );
  }

  // ============================================================
  // 🎯 إضافة درجة المقابلة للموديل
  // ============================================================
  static NominationScoreModel addInterviewScore(
    NominationScoreModel scoreModel,
    InterviewScoringModel interview,
  ) {
    return scoreModel.copyWith(
      interviewScore: interview.totalScore,
      scientificInterviewScore: interview.scientificScore,
      leadershipInterviewScore: interview.leadershipScore,
      studentActivitiesScore: interview.studentActivitiesScore,
      communityActivitiesScore: interview.communityActivitiesScore,
      humanRelationsScore: interview.humanRelationsScore,
    );
  }

  // ============================================================
  // 🎯 حساب المجموع النهائي الكلي
  // ============================================================
  static double calculateGrandTotal({
    required DoctorProfileModel doctor,
    required double interviewScore,
  }) {
    Map<String, dynamic> scores = calculateTotalScore(doctor);
    double achievementsTotal = scores['totalPoints'];
    return achievementsTotal + interviewScore;
  }

  // ============================================================
  // دوال مساعدة لعرض النصوص العربية
  // ============================================================

  static void _addActivityDetails(AcademicActivityModel activities, List<Map<String, dynamic>> details) {
    for (var c in activities.teachingCriteria) {
      if (c.proofStatus.name == 'approved' && c.awardedPoints > 0) {
        details.add({
          'title': c.titleAr,
          'type': 'نشاط تدريسي',
          'category': 'تدريسية',
          'scope': c.proofRequirement,
          'points': c.awardedPoints,
        });
      }
    }
    for (var c in activities.researchCriteria) {
      if (c.proofStatus.name == 'approved' && c.awardedPoints > 0) {
        details.add({
          'title': c.titleAr,
          'type': 'نشاط بحثي',
          'category': 'بحثية',
          'scope': c.proofRequirement,
          'points': c.awardedPoints,
        });
      }
    }
    for (var c in activities.communityCriteria) {
      if (c.proofStatus.name == 'approved' && c.awardedPoints > 0) {
        details.add({
          'title': c.titleAr,
          'type': 'نشاط مجتمعي',
          'category': 'جامعية ومجتمعية',
          'scope': c.proofRequirement,
          'points': c.awardedPoints,
        });
      }
    }
  }

  static String _getParticipationTypeAr(ParticipationType type) {
    switch (type) {
      case ParticipationType.paperPresentation: return 'بحث كامل محكم';
      case ParticipationType.abstractPresentation: return 'ملخص بحث محكم';
      case ParticipationType.attendanceOnly: return 'حضور فقط';
    }
  }

  static String _getVenueAr(ExhibitionVenue venue) {
    switch (venue) {
      case ExhibitionVenue.internationalAbroad: return 'محافل دولية بالخارج';
      case ExhibitionVenue.internationalEgypt: return 'محافل دولية بمصر';
      case ExhibitionVenue.accreditedHalls: return 'قاعات معتمدة';
      case ExhibitionVenue.publicHalls: return 'قصور ثقافة/معارض خاصة';
    }
  }

  static String _getCourseCategoryAr(CourseCategory category) {
    switch (category) {
      case CourseCategory.administrative: return 'إدارية';
      case CourseCategory.specialized: return 'متخصصة';
      case CourseCategory.general: return 'عامة';
      case CourseCategory.none: return 'غير محدد';
    }
  }

  static String _getCourseScopeAr(CourseScope scope) {
    switch (scope) {
      case CourseScope.international: return 'دولي';
      case CourseScope.local: return 'محلي';
      case CourseScope.none: return 'غير محدد';
    }
  }
}