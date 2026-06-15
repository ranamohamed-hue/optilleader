import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/doctor/data/model/activities_model.dart';
import 'package:optialeader/feature/doctor/data/model/research_paper_model.dart';

class LeadershipScoringEngine {
  // ✅✅ رقم تقديري للبحث بناءً على القانون (ممكن يتعدل حسب لائحة الجامعة)
  static const double researchBasePoints = 10.0; 

  // ✅ 1. حساب نقاط الدورات التدريبية (الدالة اللي الـ Cubit بيستدعيها لوحدها)
  static int calculateCoursePoints(List<ActivityModel> allActivities) {
    int totalPoints = 0;
    final courses = allActivities
        .where((activity) => activity.type == 'course')
        .toList();

    for (var course in courses) {
      if (course.courseCategory == CourseCategory.none ||
          course.courseScope == CourseScope.none)
        continue;
      int points = 0;

      if (course.courseCategory == CourseCategory.administrative) {
        if (course.courseScope == CourseScope.international)
          points = 6;
        else if (course.courseScope == CourseScope.local)
          points = 5;
      } else if (course.courseCategory == CourseCategory.specialized) {
        if (course.courseScope == CourseScope.international)
          points = 4;
        else if (course.courseScope == CourseScope.local)
          points = 3;
      } else if (course.courseCategory == CourseCategory.general) {
        if (course.courseScope == CourseScope.international)
          points = 2;
        else if (course.courseScope == CourseScope.local)
          points = 1;
      }
      totalPoints += points;
    }
    return totalPoints;
  }

  // ✅ 2. تفاصيل الدورات التدريبية (للجدول)
  static Map<String, dynamic> _calculateCourseData(ActivityModel course) {
    int points = 0;
    String categoryAr = 'غير محدد';
    String scopeAr = 'غير محدد';

    if (course.courseCategory == CourseCategory.administrative) {
      categoryAr = 'إدارية';
      if (course.courseScope == CourseScope.international) {
        points = 6;
        scopeAr = 'دولي';
      } else if (course.courseScope == CourseScope.local) {
        points = 5;
        scopeAr = 'محلي';
      }
    } else if (course.courseCategory == CourseCategory.specialized) {
      categoryAr = 'متخصصة';
      if (course.courseScope == CourseScope.international) {
        points = 4;
        scopeAr = 'دولي';
      } else if (course.courseScope == CourseScope.local) {
        points = 3;
        scopeAr = 'محلي';
      }
    } else if (course.courseCategory == CourseCategory.general) {
      categoryAr = 'عامة';
      if (course.courseScope == CourseScope.international) {
        points = 2;
        scopeAr = 'دولي';
      } else if (course.courseScope == CourseScope.local) {
        points = 1;
        scopeAr = 'محلي';
      }
    }

    return {
      'title': course.title,
      'type': 'دورة تدريبية',
      'category': categoryAr,
      'scope': scopeAr,
      'points': points.toDouble(),
    };
  }

  // ✅ 3. تفاصيل المؤتمرات والورش (للجدول)
  static Map<String, dynamic> _calculateEventActivityData(
    ActivityModel activity,
  ) {
    double points = 0;
    String typeAr = activity.type == 'conference' ? 'مؤتمر' : 'ورشة عمل';
    String partType = 'حضور';

    if (activity.participationType == 'speaker') {
      partType = 'متحدث';
      points = 3.0;
    } else if (activity.participationType == 'organizer') {
      partType = 'منظم';
      points = 2.0;
    } else {
      points = 1.0;
    }

    return {
      'title': activity.title,
      'type': typeAr,
      'category': partType,
      'scope': 'عام',
      'points': points,
    };
  }

  // ✅ 4. تفاصيل الأبحاث العلمية - مادة 22 (للجدول)
  static Map<String, dynamic> _calculateResearchData(ResearchPaperModel paper) {
    double percentage = calculateParticipationPercentage(
      authorOrder: paper.authorOrder,
      authorsInSameSpecialty: paper.authorsInSameSpecialty,
      isTopTierJournal: paper.isTopTierJournal,
    );

    double finalPoints = researchBasePoints * percentage;

    return {
      'title': paper.titleAr,
      'type': 'بحث علمي',
      'category': paper.isTopTierJournal ? 'مجلة درجة أولى' : 'مجلة عادية',
      'scope': 'نسبة: ${(percentage * 100).toInt()}%',
      'points': finalPoints,
    };
  }

  // ✅ 5. دالة التجميع الكبرى (اللي بترجع كل الدرجات والتفاصيل)
  static Map<String, dynamic> calculateTotalScore(DoctorProfileModel doctor) {
    List<Map<String, dynamic>> allDetails = [];
    double totalPoints = 0.0;
    double coursePoints = 0.0;
    double activitiesPoints = 0.0;
    double researchPoints = 0.0;

    // حساب الأنشطة (دورات، مؤتمرات، ورش)
    for (var activity in doctor.activities) {
      Map<String, dynamic>? detail;
      if (activity.type == 'course' &&
          activity.courseCategory != CourseCategory.none) {
        detail = _calculateCourseData(activity);
        coursePoints += detail['points'] as double;
      } else if (activity.type == 'conference' || activity.type == 'workshop') {
        detail = _calculateEventActivityData(activity);
        activitiesPoints += detail['points'] as double;
      }

      if (detail != null) {
        allDetails.add(detail);
      }
    }

    // حساب الأبحاث العلمية
    for (var paper in doctor.researchPapers) {
      final detail = _calculateResearchData(paper);
      allDetails.add(detail);
      researchPoints += detail['points'] as double;
    }

    totalPoints = coursePoints + activitiesPoints + researchPoints;

    return {
      'coursePoints': coursePoints,
      'activitiesPoints': activitiesPoints,
      'researchPoints': researchPoints,
      'totalPoints': totalPoints,
      'evaluated_items_details': allDetails,
    };
  }

  // ✅ 6. حساب نسب المشاركة (مادة 22)
  static double calculateParticipationPercentage({
    required int authorOrder,
    required int authorsInSameSpecialty,
    required bool isTopTierJournal,
  }) {
    if (authorsInSameSpecialty <= 1) return 1.0;
    if (authorOrder > authorsInSameSpecialty)
      authorOrder = authorsInSameSpecialty;
    if (authorOrder < 1) authorOrder = 1;

    if (authorOrder == 1 || authorOrder == authorsInSameSpecialty) return 1.0;

    if (isTopTierJournal) {
      if (authorsInSameSpecialty <= 4) return 1.0;
      if (authorsInSameSpecialty <= 6) return 0.8;
      return 0.6;
    }

    switch (authorsInSameSpecialty) {
      case 2:
        return 0.8;
      case 3:
        return 0.7;
      case 4:
        return 0.55;
      case 5:
        return 0.4;
      default:
        return 0.25;
    }
  }

  // ✅ 7. التحقق من الشروط الإجبارية (تم تصحيح الأخطاء الصياغية هنا)
  static List<CriterionStatus> checkMandatoryCriteria({
    required DoctorProfileModel doctor,
    required String targetRole,
  }) {
    final List<CriterionStatus> criteria = [];
    final isProfessor = _hasProfessorDegree(doctor);
    final yearsAsProfessor = doctor.yearsAsProfessor;
    final hasClearance = doctor.disciplinaryClearance;
    final noPartyPosition = !doctor.holdsPartyPosition;
    final noCriminalRecord = !doctor.hasCriminalRecord;
    final hasPreviousRole = doctor.previousLeadershipRoles.contains(targetRole);

    // ✅ رئيس الجامعة و نائب رئيس الجامعة (5 سنوات أستاذية)
    if (targetRole == 'rector' || targetRole == 'vice_rector') {
      criteria.add(CriterionStatus(
        titleAr: "أن يكون قد شغل وظيفة أستاذ لمدة 5 سنوات على الأقل", 
        titleEn: "Held Professor position for at least 5 years", 
        isMet: isProfessor && yearsAsProfessor >= 5,
      ));
      criteria.add(CriterionStatus(titleAr: "ألا يكون سبق له شغل الوظيفة بالتعيين أكثر من مرة", titleEn: "Max 1 previous appointment", isMet: !hasPreviousRole));
      criteria.add(CriterionStatus(titleAr: "ألا يكون سبق الحكم عليه بعقوبة جناية أو مخلة بالشرف", titleEn: "No criminal record", isMet: noCriminalRecord));
      // ✅✅ تم تصحيح الأقواس من )), إلى );
      criteria.add(CriterionStatus(titleAr: "ألا يكون قد وقع عليه جزاء تأديبي (ما لم يكن تم محوه)", titleEn: "No disciplinary penalties", isMet: hasClearance)); 
      criteria.add(CriterionStatus(titleAr: "ألا يكون متولياً لأي منصب حزبي", titleEn: "No party position", isMet: noPartyPosition));
      criteria.add(CriterionStatus(titleAr: "إتمام دورة تأهيل القيادات", titleEn: "Leadership Training Course", isMet: _hasLeadershipCourse(doctor), isAutoChecked: false));
    } 
    
    // ✅ عميد الكلية و وكيل الكلية (3 سنوات أستاذية)
    else if (targetRole == 'dean' || targetRole == 'vice_dean') {
      criteria.add(CriterionStatus(
        titleAr: "أن يكون في منصب أستاذ لمدة 3 سنوات على الأقل", 
        titleEn: "Held Professor position for at least 3 years", 
        isMet: isProfessor && yearsAsProfessor >= 3,
      ));
      criteria.add(CriterionStatus(titleAr: "ألا يكون سبق له شغل الوظيفة بالتعيين أكثر من مرة", titleEn: "Max 1 previous appointment", isMet: !hasPreviousRole));
      criteria.add(CriterionStatus(titleAr: "ألا يكون سبق الحكم عليه بعقوبة جناية أو مخلة بالشرف", titleEn: "No criminal record", isMet: noCriminalRecord));
      // ✅✅ تم تصحيح الأقواس من )), إلى );
      criteria.add(CriterionStatus(titleAr: "ألا يكون قد وقع عليه جزاء تأديبي (ما لم يكن تم محوه)", titleEn: "No disciplinary penalties", isMet: hasClearance)); 
      criteria.add(CriterionStatus(titleAr: "ألا يكون متولياً لأي منصب حزبي", titleEn: "No party position", isMet: noPartyPosition));
      // ✅✅ تم تصحيح الأقواس من )), إلى );
      criteria.add(CriterionStatus(titleAr: "إتمام دورة تأهيل القيادات", titleEn: "Leadership Training Course", isMet: _hasLeadershipCourse(doctor), isAutoChecked: false)); 
    } 
    
    // ✅ رئيس القسم
    else if (targetRole == 'head_department') {
      criteria.add(CriterionStatus(
        titleAr: "أن يكون ضمن أقدم 3 أساتذة بالقسم", 
        titleEn: "Top 3 Senior Professors", 
        isMet: true, 
        isAutoChecked: false, // ده لازم الأدمن يتأكد منه يدوياً
      ));
      criteria.add(CriterionStatus(titleAr: "ألا يكون سبق له شغل رئاسة القسم أكثر من مرة", titleEn: "Max 1 previous Head appointment", isMet: !hasPreviousRole));
      criteria.add(CriterionStatus(titleAr: "ألا يكون سبق الحكم عليه بعقوبة جناية أو مخلة بالشرف", titleEn: "No criminal record", isMet: noCriminalRecord));
      criteria.add(CriterionStatus(titleAr: "ألا يكون قد وقع عليه جزاء تأديبي (ما لم يكن تم محوه)", titleEn: "No disciplinary penalties", isMet: hasClearance));
      criteria.add(CriterionStatus(titleAr: "ألا يكون متولياً لأي منصب حزبي", titleEn: "No party position", isMet: noPartyPosition));
      criteria.add(CriterionStatus(titleAr: "إتمام دورة تأهيل القيادات", titleEn: "Leadership Training Course", isMet: _hasLeadershipCourse(doctor), isAutoChecked: false));
    }

    return criteria;
  }
  
  // ======> دوال مساعدة خاصة (Helpers) <======
  static bool _hasProfessorDegree(DoctorProfileModel doctor) {
    return doctor.academicHistory.any((item) {
      final degree = (item['degree'] ?? '').toString().toLowerCase();
      final normalizedDegree = degree
          .replaceAll('أ', 'ا')
          .replaceAll('إ', 'ا')
          .replaceAll('آ', 'ا');
      return normalizedDegree.contains('استاذ') || degree.contains('professor');
    });
  }

  static bool _hasLeadershipCourse(DoctorProfileModel doctor) {
    return doctor.activities.any((act) {
      final title = act.title
          .toLowerCase()
          .replaceAll('أ', 'ا')
          .replaceAll('إ', 'ا');
      return act.type == 'course' &&
          (title.contains('قيادة') ||
              title.contains('ادارة') ||
              title.contains('leadership') ||
              title.contains('management'));
    });
  }
}

// ✅ الكلاس اللي بيشيل حالة الشرط (مستوفي ولا لأ)
class CriterionStatus {
  final String titleAr;
  final String titleEn;
  final bool isMet;
  final bool isAutoChecked;

  CriterionStatus({
    required this.titleAr,
    required this.titleEn,
    required this.isMet,
    this.isAutoChecked = true,
  });
}