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
    return DoctorProfileModel(
      uid: id,
      role: json['role'] ?? 'doctor',
      isFirstLogin: json['isFirstLogin'] ?? true,
      nameAr: json['identity']?['name_ar'] ?? '',
      nameEn: json['identity']?['name_en'] ?? '',
      nationalityAr: json['identity']?['nationality_ar'] ?? '',
      nationalityEn: json['identity']?['nationality_en'] ?? '',
      currentJobAr: json['identity']?['current_job_ar'] ?? '',
      currentJobEn: json['identity']?['current_job_en'] ?? '',
      socialStatusAr: json['identity']?['social_status_ar'] ?? '',
      socialStatusEn: json['identity']?['social_status_en'] ?? '',
      nationalId: json['identity']?['national_id'] ?? '',
      employeeId: json['identity']?['employee_id'] ?? '',
      birthDate: json['identity']?['birth_date'] != null
          ? (json['identity']['birth_date'] is Timestamp
                ? (json['identity']['birth_date'] as Timestamp).toDate()
                : DateTime.tryParse(json['identity']['birth_date'].toString()))
          : null,
      profileImage: json['identity']?['profile_image_url'] ?? '',
      email: json['contact']?['university_email'] ?? '',
      phone: json['contact']?['phone_number'] ?? '',
      addressAr: json['contact']?['home_address_ar'] ?? '',
      addressEn: json['contact']?['home_address_en'] ?? '',
      alternativeEmail: json['contact']?['alternative_email'],
      academicHistory: List<Map<String, dynamic>>.from(
        json['academic_profile']?['history'] ?? [],
      ),
      disciplinaryClearance:
          json['eligibility_data']?['disciplinary_clearance'] ?? true,
      hasPermanentPosition:
          json['eligibility_data']?['has_permanent_position'] ?? true,
      isOnVacation: json['eligibility_data']?['is_on_vacation'] ?? false,
      isActive: json['eligibility_data']?['is_active'] ?? true,
      cvUrl: json['academic_profile']?['cv_url'],

      // ✅ القراءة باستخدام الموديلات الجديدة
      researchPapers: List<ResearchPaperModel>.from(
        (json['scientific_work']?['research_papers'] ?? []).map(
          (x) => ResearchPaperModel.fromJson(x),
        ),
      ),
      trainingCourses: List<ActivityModel>.from(
        (json['scientific_work']?['training_courses'] ?? []).map(
          (x) => ActivityModel.fromJson(x),
        ),
      ),
      activities: List<ActivityModel>.from(
        (json['scientific_work']?['other_activities'] ?? []).map(
          (x) => ActivityModel.fromJson(x),
        ),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid ?? '',
      'role': role,
      'isFirstLogin': isFirstLogin,
      'identity': {
        'name_ar': nameAr,
        'name_en': nameEn,
        'nationality_ar': nationalityAr,
        'nationality_en': nationalityEn,
        'current_job_ar': currentJobAr,
        'current_job_en': currentJobEn,
        'national_id': nationalId,
        'employee_id': employeeId,
        'birth_date': birthDate,
        'profile_image_url': profileImage,
        'social_status_ar': socialStatusAr,
        'social_status_en': socialStatusEn,
      },
      'contact': {
        'university_email': email,
        'alternative_email': alternativeEmail ?? "",
        'phone_number': phone,
        'home_address_ar': addressAr,
        'home_address_en': addressEn,
      },
      'academic_profile': {'history': academicHistory, 'cv_url': cvUrl},
      'eligibility_data': {
        'is_on_vacation': isOnVacation,
        'has_permanent_position': hasPermanentPosition,
        'disciplinary_clearance': disciplinaryClearance,
        'is_active': isActive,
      },
      // ✅ الكتابة باستخدام الموديلات الجديدة
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
