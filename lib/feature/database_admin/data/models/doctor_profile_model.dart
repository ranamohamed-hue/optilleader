import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:optialeader/feature/doctor/data/model/activities_model.dart';
import 'package:optialeader/feature/doctor/data/model/research_paper_model.dart';

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

  // بيانات التواصل
  final String email;
  final String phone;
  final String addressAr;
  final String addressEn;
  final String? alternativeEmail;

  // البيانات الأكاديمية
  final List<Map<String, dynamic>>
  academicHistory; // دي هتفضل Map مؤقتاً لحد ما نعرف هيكلها

  // البيانات الأهلية والإدارية
  final bool disciplinaryClearance;
  final bool hasPermanentPosition;
  final bool isOnVacation;
  final bool isActive;

  // الأبحاث والأنشطة (✅ تم التعديل)
  final String? cvUrl;
  final List<ResearchPaperModel> researchPapers;
  final List<ActivityModel> trainingCourses;
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
    required this.email,
    required this.phone,
    required this.addressAr,
    required this.addressEn,
    this.alternativeEmail,
    required this.academicHistory,
    required this.disciplinaryClearance,
    required this.hasPermanentPosition,
    required this.isOnVacation,
    this.isActive = true,
    this.cvUrl = "",
    this.researchPapers = const [],
    this.trainingCourses = const [],
    this.activities = const [],
  });
  factory DoctorProfileModel.fromJson(Map<String, dynamic> json, String id) {
    // ✅ أفضل طريقة لقراءة الـ List of Models بأمان
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

    // استخراج بيانات الـ profile القديمة عشان تتوافق مع الباقي
    final profile = json['profile'] as Map<String, dynamic>? ?? {};

    return DoctorProfileModel(
      uid: id,
      role: json['role'] ?? 'doctor',
      isFirstLogin: json['isFirstLogin'] ?? true,

      // بيانات الهوية (متوافقة مع هيكل profile القديم)
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
      birthDate: profile['birth_date'] != null
          ? (profile['birth_date'] is Timestamp
                ? (profile['birth_date'] as Timestamp).toDate()
                : DateTime.tryParse(profile['birth_date'].toString()))
          : null,
      profileImage: profile['profile_image'] ?? '',

      // بيانات التواصل (متوافقة مع الهيكل القديم)
      email: json['university_email'] ?? '',
      phone: profile['phone']?['phone1'] ?? '',
      addressAr: profile['address']?['ar'] ?? '',
      addressEn: profile['address']?['en'] ?? '',
      alternativeEmail: json['alternative_email'] ?? '',

      // البيانات الأكاديمية
      academicHistory: List<Map<String, dynamic>>.from(
        json['academic_profile']?['history'] ?? [],
      ),

      // البيانات الأهلية والإدارية
      disciplinaryClearance:
          json['eligibility_data']?['disciplinary_clearance'] ?? true,
      hasPermanentPosition:
          json['eligibility_data']?['has_permanent_position'] ?? true,
      isOnVacation: json['eligibility_data']?['is_on_vacation'] ?? false,
      isActive:
          json['is_active'] ?? json['eligibility_data']?['is_active'] ?? true,
      cvUrl: json['academic_profile']?['cv_url'],

      // الأبحاث والأنشطة (بطريقة آمنة)
      researchPapers: parseResearchPapers(
        json['scientific_work']?['research_papers'],
      ),
      trainingCourses: parseActivities(
        json['scientific_work']?['training_courses'],
      ),
      activities: parseActivities(json['scientific_work']?['other_activities']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid ?? '',
      'role': role,
      'isFirstLogin': isFirstLogin,
      // متوافق مع باقي المستخدمين
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
      },
      // بيانات الدكتور الخاصة
      'academic_profile': {'history': academicHistory, 'cv_url': cvUrl},
      'eligibility_data': {
        'is_on_vacation': isOnVacation,
        'has_permanent_position': hasPermanentPosition,
        'disciplinary_clearance': disciplinaryClearance,
        'is_active': isActive,
      },
      'scientific_work': {
        'research_papers': researchPapers.map((x) => x.toMap()).toList(),
        'training_courses': trainingCourses.map((x) => x.toMap()).toList(),
        'other_activities': activities.map((x) => x.toMap()).toList(),
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
    List<ResearchPaperModel>? researchPapers, // ✅
    List<ActivityModel>? trainingCourses, // ✅
    List<ActivityModel>? activities, // ✅
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
      email: email ?? this.email,
      phone: phone ?? this.phone,
      addressAr: addressAr ?? this.addressAr,
      addressEn: addressEn ?? this.addressEn,
      alternativeEmail: alternativeEmail ?? this.alternativeEmail,
      academicHistory: academicHistory ?? this.academicHistory,
      disciplinaryClearance:
          disciplinaryClearance ?? this.disciplinaryClearance,
      hasPermanentPosition: hasPermanentPosition ?? this.hasPermanentPosition,
      isOnVacation: isOnVacation ?? this.isOnVacation,
      isActive: isActive ?? this.isActive,
      cvUrl: cvUrl ?? this.cvUrl,
      researchPapers: researchPapers ?? this.researchPapers,
      trainingCourses: trainingCourses ?? this.trainingCourses,
      activities: activities ?? this.activities,
    );
  }
}
