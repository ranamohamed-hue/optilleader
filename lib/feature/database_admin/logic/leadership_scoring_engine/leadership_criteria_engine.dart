import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/doctor/logic/activities/mandatory_leadership_data.dart';

class LeadershipCriteriaEngine {

  /// ✅ تم إضافة departmentDoctors هنا
  static List<CriterionStatus> checkMandatoryCriteria({
    required DoctorProfileModel doctor,
    required String targetRole,
    List<DoctorProfileModel> departmentDoctors = const [],
  }) {
    final List<CriterionStatus> criteria = [];

    // الشروط الأساسية المشتركة
    criteria.addAll(_getCommonCriteria(doctor));

    // شروط خاصة بكل وظيفة
    switch (targetRole) {
      case 'dean':
        criteria.addAll(_getDeanCriteria(doctor));
        break;
      case 'vice_dean':
        criteria.addAll(_getViceDeanCriteria(doctor));
        break;
      case 'head_department':
        // ✅ تمرير الدكاترة لشروط رئيس القسم
        criteria.addAll(_getHeadDepartmentCriteria(doctor, departmentDoctors));
        break;
      case 'quality_manager':
        criteria.addAll(_getQualityManagerCriteria(doctor));
        break;
      case 'admin_manager':
        criteria.addAll(_getAdminManagerCriteria(doctor));
        break;
    }

    return criteria;
  }

  // ============================================================
  // الشروط المشتركة
  // ============================================================
  static List<CriterionStatus> _getCommonCriteria(DoctorProfileModel doctor) {
    return [
      CriterionStatus(
        titleAr: "أن يكون مصري الجنسية",
        titleEn: "Must be Egyptian",
        isMet: _isEgyptian(doctor),
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "ألا يكون سبق الحكم عليه بعقوبة جناية أو مخلة بالشرف",
        titleEn: "No criminal record",
        isMet: !doctor.hasCriminalRecord,
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "ألا يكون قد وقع عليه جزاء تأديبي (ما لم يكن تم محوه)",
        titleEn: "No disciplinary penalties",
        isMet: doctor.disciplinaryClearance,
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "ألا يكون متولياً لأي منصب حزبي",
        titleEn: "No party position",
        isMet: !doctor.holdsPartyPosition,
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "إجادة التعامل مع الحاسب الآلي (ICDL)",
        titleEn: "Computer skills (ICDL)",
        isMet: doctor.hasICDL,
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "إتمام دورتين تدريبيتين على الأقل في مجالات القيادة",
        titleEn: "At least 2 Leadership Training Courses",
        isMet: _hasRequiredLeadershipCourses(doctor),
        isAutoChecked: true,
      ),
    ];
  }

  // ============================================================
  // شروط العميد
  // ============================================================
  static List<CriterionStatus> _getDeanCriteria(DoctorProfileModel doctor) {
    final yearsAsProf = _calculateYearsSince(doctor.professorRankDate);

    return [
      CriterionStatus(
        titleAr: "أن يكون في منصب أستاذ لمدة 3 سنوات على الأقل",
        titleEn: "Held Professor position for at least 3 years",
        isMet: _hasProfessorDegree(doctor) && yearsAsProf >= 3,
        isAutoChecked: true,
        details: yearsAsProf > 0 ? "عدد السنوات: $yearsAsProf سنة" : null,
      ),
      CriterionStatus(
        titleAr: "الحصول على درجة الدكتوراه",
        titleEn: "Holds a PhD",
        isMet: _hasPhdDegree(doctor),
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "ألا يكون سبق له شغل الوظيفة لمدتين كاملتين (6 سنوات)",
        titleEn: "Has not served for two full terms",
        isMet: !doctor.previousLeadershipRoles.contains('dean'),
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "التمتع بالسلامة الصحية والقدرة على العمل لساعات طويلة",
        titleEn: "Good health and ability to work long hours",
        isMet: doctor.hasHealthCertificate ?? false,
        isAutoChecked: true,
      ),
    ];
  }

  // ============================================================
  // شروط وكيل الكلية
  // ============================================================
  static List<CriterionStatus> _getViceDeanCriteria(DoctorProfileModel doctor) {
    return [
      ..._getDeanCriteria(doctor),
      CriterionStatus(
        titleAr: "العضوية في إحدى لجان الجامعة",
        titleEn: "Membership in a University Committee",
        isMet: _hasInternalCommittees(doctor),
        isAutoChecked: true,
        details: doctor.internalCommittees.isNotEmpty
            ? doctor.internalCommittees.join(' • ')
            : null,
      ),
    ];
  }

  // ============================================================
  // ✅ شروط رئيس القسم (مع الحساب الديناميكي لأقدم 3)
  // ============================================================
  static List<CriterionStatus> _getHeadDepartmentCriteria(
      DoctorProfileModel doctor, List<DoctorProfileModel> departmentDoctors) {
    
    bool isTop3 = false;
    String? details;

    if (departmentDoctors.isNotEmpty) {
      // 1. فلترة دكاترة نفس القسم اللي عندهم تاريخ أستاذية
      final profsInDept = departmentDoctors.where((d) {
        return d.departmentAr == doctor.departmentAr && 
               d.professorRankDate != null &&
               d.uid != null;
      }).toList();

      if (profsInDept.isNotEmpty) {
        // 2. ترتيب تصاعدي حسب تاريخ الأستاذية (الأقدم ييجي الأول)
        profsInDept.sort((a, b) => a.professorRankDate!.compareTo(b.professorRankDate!));

        // 3. أخد أول 3
        final top3Uids = profsInDept.take(3).map((d) => d.uid!).toSet();

        // 4. التحقق هل الدكتور ده ضمنهم
        isTop3 = top3Uids.contains(doctor.uid);
        details = isTop3 
            ? "يقع ضمن أقدم 3 أساتذة بالقسم" 
            : "غير ضمن أقدم 3 أساتذة القسم (عدد الأساتذة بالقسم: ${profsInDept.length})";
      } else {
        details = "لا يوجد بيانات أستاذية كافية لقسمك للتحقق التلقائي";
      }
    } else {
      // Fallback لو مفيش داتا
      isTop3 = doctor.isTop3Senior ?? false;
      details = "لم يتم التحقق التلقائي (يعتمد على الإدخال اليدوي للأدمن)";
    }

    return [
      CriterionStatus(
        titleAr: "أن يكون ضمن أقدم 3 أساتذة بالقسم",
        titleEn: "Top 3 Senior Professors",
        isMet: isTop3,
        isAutoChecked: true,
        details: details,
      ),
      CriterionStatus(
        titleAr: "ألا يكون سبق له شغل رئاسة القسم أكثر من مرة",
        titleEn: "Max 1 previous Head appointment",
        isMet: !doctor.previousLeadershipRoles.contains('head_department'),
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "المشاركة في اللجان الداخلية بالجامعة",
        titleEn: "Participation in internal university committees",
        isMet: _hasInternalCommittees(doctor),
        isAutoChecked: true,
        details: doctor.internalCommittees.isNotEmpty
            ? doctor.internalCommittees.join(' • ')
            : null,
      ),
    ];
  }

  // ============================================================
  // شروط مدير الجودة
  // ============================================================
  static List<CriterionStatus> _getQualityManagerCriteria(
      DoctorProfileModel doctor) {
    return [
      CriterionStatus(
        titleAr: "أن يكون قد عمل بوظيفة مدرس بأحد الأقسام العلمية",
        titleEn: "Worked as Lecturer",
        isMet: _hasLecturerDegree(doctor),
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "الحصول على دورات الهيئة القومية لضمان الجودة",
        titleEn: "National Authority for Quality Assurance courses",
        isMet: _hasApprovedQualityCourses(doctor),
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "تقرير التقييم الذاتي",
        titleEn: "Self-evaluation report",
        isMet: doctor.hasSelfEvaluationReport ?? false,
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "خطة التحكيم",
        titleEn: "Arbitration plan",
        isMet: doctor.hasArbitrationPlan ?? false,
        isAutoChecked: true,
      ),
    ];
  }

  // ============================================================
  // شروط القيادات الإدارية
  // ============================================================
  static List<CriterionStatus> _getAdminManagerCriteria(
      DoctorProfileModel doctor) {
    final yearsOfExperience = _calculateYearsSince(doctor.hiringDate);

    return [
      CriterionStatus(
        titleAr: "خبرة في مجال العمل الإداري لا تقل عن عشر سنوات",
        titleEn: "At least 10 years admin experience",
        isMet: yearsOfExperience >= 10,
        isAutoChecked: true,
        details: "عدد سنوات الخبرة: $yearsOfExperience سنة",
      ),
      CriterionStatus(
        titleAr: "الحصول على مؤهل جامعي",
        titleEn: "Holds a university degree",
        isMet: _hasUniversityDegree(doctor),
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr:
            "الحصول على تقدير امتياز في آخر أربعة تقارير لتقييم الأداء",
        titleEn: "Excellent rating in last 4 performance reports",
        isMet: doctor.hasExcellentPerformanceReports ?? false,
        isAutoChecked: true,
      ),
      CriterionStatus(
        titleAr: "عدم توقيع أي جزاءات عليه في السنوات الخمس الأخيرة",
        titleEn: "No penalties in last 5 years",
        isMet: doctor.disciplinaryClearance,
        isAutoChecked: true,
      ),
    ];
  }

  // ============================================================
  // دوال التحقق المساعدة
  // ============================================================

  static int _calculateYearsSince(DateTime? startDate) {
    if (startDate == null) return 0;
    final now = DateTime.now();
    int years = now.year - startDate.year;
    if (now.month < startDate.month || 
        (now.month == startDate.month && now.day < startDate.day)) {
      years--;
    }
    return years < 0 ? 0 : years;
  }

  static bool _isEgyptian(DoctorProfileModel doctor) {
    return doctor.nationalityAr.contains('مصري') ||
        doctor.nationalityEn.toLowerCase().contains('egyptian');
  }

  static bool _hasRequiredLeadershipCourses(DoctorProfileModel doctor) {
    int count = 0;
    for (var course in doctor.courses) {
      if (course.status.name != 'approved') continue;
      
      final title = _normalizeArabic(course.title.toLowerCase());

      // ✅ استبعاد دورة ICDL
      if (title.contains('icdl') || 
          title.contains('الحاسب الالي') || 
          title.contains('الحاسوب')) {
        continue;
      }

      for (var mandatory in MandatoryLeadershipData.courses) {
        final mandatoryTitle =
            _normalizeArabic(mandatory['titleAr']!.toLowerCase());
        if (title.contains(mandatoryTitle) || title == mandatoryTitle) {
          count++;
          break;
        }
      }
      if (count >= 2) return true;
    }
    return false;
  }

  static bool _hasInternalCommittees(DoctorProfileModel doctor) {
    return doctor.internalCommittees.isNotEmpty;
  }

  static bool _hasApprovedQualityCourses(DoctorProfileModel doctor) {
    const qualityCourseKeywords = [
      'الهيئة القومية لضمان الجودة',
      'ضمان الجودة',
      'اعتماد المؤسسات',
      'national authority for quality',
      'quality assurance',
      'accreditation',
    ];
    int count = 0;
    for (var course in doctor.courses) {
      if (course.status.name != 'approved') continue;
      final title = _normalizeArabic(course.title.toLowerCase());
      for (var keyword in qualityCourseKeywords) {
        if (title.contains(_normalizeArabic(keyword))) {
          count++;
          break;
        }
      }
    }
    return count >= 2;
  }

  static bool _hasProfessorDegree(DoctorProfileModel doctor) {
    return doctor.academicHistory.any((item) {
      final degree = (item['degree'] ?? '').toString().toLowerCase();
      return _normalizeArabic(degree).contains('استاذ') ||
          degree.contains('professor');
    });
  }

  static bool _hasPhdDegree(DoctorProfileModel doctor) {
    return doctor.academicHistory.any((item) {
      final degree = (item['degree'] ?? '').toString().toLowerCase();
      return _normalizeArabic(degree).contains('دكتوراه') ||
          degree.contains('phd') ||
          degree.contains('doctorate');
    });
  }

  static bool _hasLecturerDegree(DoctorProfileModel doctor) {
    return doctor.academicHistory.any((item) {
      final degree = (item['degree'] ?? '').toString().toLowerCase();
      return _normalizeArabic(degree).contains('مدرس') ||
          degree.contains('lecturer') ||
          degree.contains('assistant professor');
    });
  }

  static bool _hasUniversityDegree(DoctorProfileModel doctor) {
    return doctor.academicHistory.any((item) {
      final degree = (item['degree'] ?? '').toString().toLowerCase();
      final normalized = _normalizeArabic(degree);
      return normalized.contains('بكالوريوس') ||
          normalized.contains('ليسانس') ||
          normalized.contains('ماجستير') ||
          normalized.contains('دكتوراه') ||
          normalized.contains('استاذ') ||
          degree.contains('bachelor') ||
          degree.contains('master') ||
          degree.contains('phd') ||
          degree.contains('professor');
    });
  }

  static String _normalizeArabic(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');
  }
}

/// ✅ موديل حالة الشرط
class CriterionStatus {
  final String titleAr;
  final String titleEn;
  final bool isMet;
  final bool isAutoChecked;
  final String? details; 

  CriterionStatus({
    required this.titleAr,
    required this.titleEn,
    required this.isMet,
    this.isAutoChecked = true,
    this.details,
  });
}