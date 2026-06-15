import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:optialeader/feature/doctor/data/model/activities_model.dart';
import 'package:optialeader/feature/doctor/data/model/research_paper_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';

class DoctorProfileModel {
  final String? uid;
  final String role;
  final bool isFirstLogin;

  // بيانات الهوية
  final String nameAr;
  final String nameEn;
  final String nationalityAr;
  final String nationalityEn;
  final String currentJobAr;
  final String currentJobEn;
  final String socialStatusAr;
  final String socialStatusEn;
  final String nationalId;
  final String employeeId;
  final DateTime? birthDate;
  final String profileImage;

  // البيانات الأكاديمية والوظيفية
  final String universityAr;
  final String universityEn;
  final String facultyAr;
  final String facultyEn;
  final String departmentAr;
  final String departmentEn;

  // القيادات الأكاديمية
  final DateTime? professorRankDate;
  final List<String> previousLeadershipRoles;
  final bool hasCriminalRecord;
  final bool holdsPartyPosition;

  // بيانات التواصل
  final String email;
  final String phone;
  final String addressAr;
  final String addressEn;
  final String? alternativeEmail;

  // البيانات الأكاديمية (تاريخ الشهادات)
  final List<Map<String, dynamic>> academicHistory;

  // البيانات الجديدة: ملفات الأرشيف
  final List<Map<String, dynamic>> digitalArchive;

  // البيانات الأهلية والإدارية
  final bool disciplinaryClearance;
  final bool hasPermanentPosition;
  final bool isOnVacation;
  final bool isActive;

  // الأبحاث والأنشطة
  final String? cvUrl;
  final List<ResearchPaperModel> researchPapers;
  final List<ActivityModel> activities;

  DoctorProfileModel({
    this.uid,
    this.role = 'doctor',
    this.isFirstLogin = true,
    required this.nameAr,
    required this.nameEn,
    required this.nationalityAr,
    required this.nationalityEn,
    required this.currentJobAr,
    required this.currentJobEn,
    required this.socialStatusAr,
    required this.socialStatusEn,
    required this.nationalId,
    required this.employeeId,
    this.birthDate,
    required this.profileImage,
    this.universityAr = '',
    this.universityEn = '',
    this.facultyAr = '',
    this.facultyEn = '',
    this.departmentAr = '',
    this.departmentEn = '',
    this.professorRankDate,
    this.previousLeadershipRoles = const [],
    this.hasCriminalRecord = false,
    this.holdsPartyPosition = false,
    required this.email,
    required this.phone,
    required this.addressAr,
    required this.addressEn,
    this.alternativeEmail,
    required this.academicHistory,
    required this.digitalArchive, // مطلوب
    required this.disciplinaryClearance,
    required this.hasPermanentPosition,
    required this.isOnVacation,
    this.isActive = true,
    this.cvUrl = "",
    this.researchPapers = const [],
    this.activities = const [],
  });

  factory DoctorProfileModel.fromJson(Map<String, dynamic> json, String id) {
    List<ResearchPaperModel> parseResearchPapers(List<dynamic>? list) {
      if (list == null) return [];
      List<ResearchPaperModel> result = [];
      for (var item in list) {
        try {
          result.add(ResearchPaperModel.fromJson(item as Map<String, dynamic>));
        } catch (e) {
          print("Error parsing research paper: $e");
        }
      }
      return result;
    }

    List<ActivityModel> parseActivities(List<dynamic>? list) {
      if (list == null) return [];
      List<ActivityModel> result = [];
      for (var item in list) {
        try {
          result.add(ActivityModel.fromJson(item as Map<String, dynamic>));
        } catch (e) {
          print("Error parsing activity: $e");
        }
      }
      return result;
    }

    final profile = json['profile'] as Map<String, dynamic>? ?? {};

    DateTime? parseDate(dynamic dateField) {
      if (dateField == null) return null;
      if (dateField is Timestamp) return dateField.toDate();
      return DateTime.tryParse(dateField.toString());
    }

    final List<ActivityModel> allActivities = [];
    allActivities.addAll(
      parseActivities(json['scientific_work']?['activities']),
    );
    allActivities.addAll(
      parseActivities(json['scientific_work']?['training_courses']),
    );
    allActivities.addAll(
      parseActivities(json['scientific_work']?['other_activities']),
    );

    List<Map<String, dynamic>> historyList = [];
    final historyData = json['academic_profile']?['history'];
    if (historyData != null && historyData is List) {
      for (var item in historyData) {
        if (item is Map<String, dynamic>) {
          historyList.add({
            'degree': item['degree'] ?? '',
            'major': item['major'] ?? '',
            'date': parseDate(item['date']),
            'place': item['place'] ?? '',
            'type': item['type'] ?? 'degree',
          });
        }
      }
    }

    // قراءة ملفات الأرشيف
    List<Map<String, dynamic>> archiveList = [];
    if (json['digital_archive'] != null && json['digital_archive'] is List) {
      for (var item in json['digital_archive']) {
        if (item is Map<String, dynamic>) {
          archiveList.add({
            'title': item['title'] ?? '',
            'description': item['description'] ?? '',
            'category': item['category'] ?? '',
            'file_url': item['file_url'] ?? '',
            'uploaded_at': item['uploaded_at'] ?? '',
          });
        }
      }
    }

    return DoctorProfileModel(
      uid: id,
      role: json['role'] ?? 'doctor',
      isFirstLogin: json['isFirstLogin'] ?? true,
      nameAr: profile['display_name']?['ar'] ?? '',
      nameEn: profile['display_name']?['en'] ?? '',
      nationalityAr: profile['nationality_ar'] ?? '',
      nationalityEn: profile['nationality_en'] ?? '',
      currentJobAr:
          profile['current_job_ar'] ?? json['jop']?['title']?['ar'] ?? '',
      currentJobEn:
          profile['current_job_en'] ?? json['jop']?['title']?['en'] ?? '',
      socialStatusAr: profile['social_status_ar'] ?? '',
      socialStatusEn: profile['social_status_en'] ?? '',
      nationalId: json['national_id'] ?? '',
      employeeId: json['employee_id'] ?? '',
      birthDate: parseDate(profile['birth_date']),
      profileImage: profile['profile_image'] ?? '',
      universityAr:
          profile['university_ar'] ??
          json['academic_profile']?['university_ar'] ??
          '',
      universityEn:
          profile['university_en'] ??
          json['academic_profile']?['university_en'] ??
          '',
      facultyAr:
          profile['faculty_ar'] ??
          json['academic_profile']?['faculty_ar'] ??
          '',
      facultyEn:
          profile['faculty_en'] ??
          json['academic_profile']?['faculty_en'] ??
          '',
      departmentAr:
          profile['department_ar'] ??
          json['academic_profile']?['department_ar'] ??
          '',
      departmentEn:
          profile['department_en'] ??
          json['academic_profile']?['department_en'] ??
          '',
      professorRankDate: parseDate(
        json['academic_profile']?['professor_rank_date'],
      ),
      previousLeadershipRoles: List<String>.from(
        json['leadership_data']?['previous_roles'] ?? [],
      ),
      hasCriminalRecord: json['security_data']?['has_criminal_record'] ?? false,
      holdsPartyPosition:
          json['security_data']?['holds_party_position'] ?? false,
      email: json['university_email'] ?? '',
      phone: profile['phone']?['phone1'] ?? '',
      addressAr: profile['address']?['ar'] ?? '',
      addressEn: profile['address']?['en'] ?? '',
      alternativeEmail: json['alternative_email'] ?? '',
      academicHistory: historyList,
      digitalArchive: archiveList,
      disciplinaryClearance:
          json['eligibility_data']?['disciplinary_clearance'] ?? true,
      hasPermanentPosition:
          json['eligibility_data']?['has_permanent_position'] ?? true,
      isOnVacation: json['eligibility_data']?['is_on_vacation'] ?? false,
      isActive:
          json['is_active'] ?? json['eligibility_data']?['is_active'] ?? true,
      cvUrl: json['academic_profile']?['cv_url'],
      researchPapers: parseResearchPapers(
        json['scientific_work']?['research_papers'],
      ),
      activities: allActivities,
    );
  }

  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> historyMap = academicHistory.map((historyItem) {
      return {
        'degree': historyItem['degree'],
        'major': historyItem['major'],
        'date': historyItem['date'] != null
            ? Timestamp.fromDate(historyItem['date'] as DateTime)
            : null,
        'place': historyItem['place'],
        'type': historyItem['type'],
      };
    }).toList();

    List<Map<String, dynamic>> archiveMap = digitalArchive.map((item) {
      return {
        'title': item['title'],
        'description': item['description'],
        'category': item['category'],
        'file_url': item['file_url'],
        'uploaded_at': item['uploaded_at'],
      };
    }).toList();

    return {
      'uid': uid ?? '',
      'role': role,
      'isFirstLogin': isFirstLogin,
      'university_email': email,
      'alternative_email': alternativeEmail ?? "",
      'national_id': nationalId,
      'employee_id': employeeId,
      'is_active': isActive,
      'profile': {
        'display_name': {'ar': nameAr, 'en': nameEn},
        'phone': {'phone1': phone},
        'address': {'ar': addressAr, 'en': addressEn},
        'profile_image': profileImage,
        'nationality_ar': nationalityAr,
        'nationality_en': nationalityEn,
        'current_job_ar': currentJobAr,
        'current_job_en': currentJobEn,
        'social_status_ar': socialStatusAr,
        'social_status_en': socialStatusEn,
        'birth_date': birthDate,
        'university_ar': universityAr,
        'university_en': universityEn,
        'faculty_ar': facultyAr,
        'faculty_en': facultyEn,
        'department_ar': departmentAr,
        'department_en': departmentEn,
      },
      'academic_profile': {
        'history': historyMap,
        'cv_url': cvUrl,
        'professor_rank_date': professorRankDate != null
            ? Timestamp.fromDate(professorRankDate!)
            : null,
      },
      'eligibility_data': {
        'is_on_vacation': isOnVacation,
        'has_permanent_position': hasPermanentPosition,
        'disciplinary_clearance': disciplinaryClearance,
        'is_active': isActive,
      },
      'leadership_data': {'previous_roles': previousLeadershipRoles},
      'security_data': {
        'has_criminal_record': hasCriminalRecord,
        'holds_party_position': holdsPartyPosition,
      },
      'digital_archive': archiveMap,
      'scientific_work': {
        'research_papers': researchPapers.map((x) => x.toMap()).toList(),
        'activities': activities.map((x) => x.toMap()).toList(),
      },
    };
  }

  DoctorProfileModel copyWith({
    String? uid,
    String? role,
    bool? isFirstLogin,
    String? nameAr,
    String? nameEn,
    String? nationalityAr,
    String? nationalityEn,
    String? currentJobAr,
    String? currentJobEn,
    String? socialStatusAr,
    String? socialStatusEn,
    String? nationalId,
    String? employeeId,
    DateTime? birthDate,
    String? profileImage,
    String? universityAr,
    String? universityEn,
    String? facultyAr,
    String? facultyEn,
    String? departmentAr,
    String? departmentEn,
    DateTime? professorRankDate,
    List<String>? previousLeadershipRoles,
    bool? hasCriminalRecord,
    bool? holdsPartyPosition,
    String? email,
    String? phone,
    String? addressAr,
    String? addressEn,
    String? alternativeEmail,
    List<Map<String, dynamic>>? academicHistory,
    bool? disciplinaryClearance,
    bool? hasPermanentPosition,
    bool? isOnVacation,
    bool? isActive,
    String? cvUrl,
    List<ResearchPaperModel>? researchPapers,
    List<ActivityModel>? activities,
    List<Map<String, dynamic>>? digitalArchive,
  }) {
    return DoctorProfileModel(
      uid: uid ?? this.uid,
      role: role ?? this.role,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      nationalityAr: nationalityAr ?? this.nationalityAr,
      nationalityEn: nationalityEn ?? this.nationalityEn,
      currentJobAr: currentJobAr ?? this.currentJobAr,
      currentJobEn: currentJobEn ?? this.currentJobEn,
      socialStatusAr: socialStatusAr ?? this.socialStatusAr,
      socialStatusEn: socialStatusEn ?? this.socialStatusEn,
      nationalId: nationalId ?? this.nationalId,
      employeeId: employeeId ?? this.employeeId,
      birthDate: birthDate ?? this.birthDate,
      profileImage: profileImage ?? this.profileImage,
      universityAr: universityAr ?? this.universityAr,
      universityEn: universityEn ?? this.universityEn,
      facultyAr: facultyAr ?? this.facultyAr,
      facultyEn: facultyEn ?? this.facultyEn,
      departmentAr: departmentAr ?? this.departmentAr,
      departmentEn: departmentEn ?? this.departmentEn,
      professorRankDate: professorRankDate ?? this.professorRankDate,
      previousLeadershipRoles:
          previousLeadershipRoles ?? this.previousLeadershipRoles,
      hasCriminalRecord: hasCriminalRecord ?? this.hasCriminalRecord,
      holdsPartyPosition: holdsPartyPosition ?? this.holdsPartyPosition,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      addressAr: addressAr ?? this.addressAr,
      addressEn: addressEn ?? this.addressEn,
      alternativeEmail: alternativeEmail ?? this.alternativeEmail,
      academicHistory: academicHistory ?? this.academicHistory,
      digitalArchive: digitalArchive ?? this.digitalArchive,
      disciplinaryClearance:
          disciplinaryClearance ?? this.disciplinaryClearance,
      hasPermanentPosition: hasPermanentPosition ?? this.hasPermanentPosition,
      isOnVacation: isOnVacation ?? this.isOnVacation,
      isActive: isActive ?? this.isActive,
      cvUrl: cvUrl ?? this.cvUrl,
      researchPapers: researchPapers ?? this.researchPapers,
      activities: activities ?? this.activities,
    );
  }

  // ==========================================================
  // الـ Getters بتاعة الإحصائيات والمتطلبات
  // ==========================================================

  int get totalAchievements => researchPapers.length + activities.length;

  int get totalApprovedAchievements {
    final approvedResearch = researchPapers
        .where((p) => p.status == VerificationStatus.approved)
        .length;
    final approvedActivities = activities
        .where((a) => a.status == VerificationStatus.approved)
        .length;
    return approvedResearch + approvedActivities;
  }

  int get totalPendingAchievements {
    final pendingResearch = researchPapers
        .where((p) => p.status == VerificationStatus.pending)
        .length;
    final pendingActivities = activities
        .where((a) => a.status == VerificationStatus.pending)
        .length;
    return pendingResearch + pendingActivities;
  }

  int get totalConferences =>
      activities.where((a) => a.type == 'conference').length;
  int get totalWorkshops =>
      activities.where((a) => a.type == 'workshop').length;
  int get totalCourses => activities.where((a) => a.type == 'course').length;

  int get totalApprovedResearch => researchPapers
      .where((p) => p.status == VerificationStatus.approved)
      .length;

  int get yearsAsProfessor {
    if (professorRankDate == null) return 0;
    final now = DateTime.now();
    int years = now.year - professorRankDate!.year;

    // التحقق من هل أكمل السنة الحالية بالكامل
    if (now.month < professorRankDate!.month ||
        (now.month == professorRankDate!.month &&
            now.day < professorRankDate!.day)) {
      years--;
    }
    return years;
  }
}
