import 'package:flutter/material.dart';
import 'package:optialeader/feature/database_admin/data/models/database_admin_model.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';

// 1. الموديل الوسيط لشاشة الإعدادات (عربي وإنجليزي)
class UserSettingsModel {
  final String uid;
  final String username; 
  final String email;
  final String addressAr;
  final String addressEn;
  final String phone;
  final String profileImage;

  UserSettingsModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.addressAr,
    required this.addressEn,
    required this.phone,
    required this.profileImage,
  });
factory UserSettingsModel.fromFirestore(Map<String, dynamic> json, String documentId) {
    return UserSettingsModel(
      uid: documentId, 
      username: json['username'] ?? '',
      email: json['email'] ?? '',
    
      addressAr: json['addressAr'] ?? json['address'] ?? '', 
      addressEn: json['addressEn'] ?? '',
      phone: json['phone'] ?? json['phone1'] ?? '',
      profileImage: json['profileImage'] ?? '',
    );
  }
  // التحويل من أدمن (AdminProfileModel)
  factory UserSettingsModel.fromAdmin(AdminProfileModel admin) {
    return UserSettingsModel(
      uid: admin.uid,
      username: admin.nameAr,
      email: admin.email,
      addressAr: admin.addressAr,
      addressEn: admin.addressEn,
      phone: admin.phone,
      profileImage: admin.profileImage,
    );
  }

  // التحويل من دكتور (DoctorProfileModel)
  factory UserSettingsModel.fromDoctor(DoctorProfileModel doctor) {
    return UserSettingsModel(
      uid: doctor.uid ?? '',
      username: doctor.nameAr,
      email: doctor.email,
      addressAr: doctor.addressAr,
      addressEn: doctor.addressEn,
      phone: doctor.phone,
      profileImage: doctor.profileImage,
    );
  }

  // التحويل من محكم (JudgeProfileModel)
  factory UserSettingsModel.fromJudge(JudgeProfileModel judge) {
    return UserSettingsModel(
      uid: judge.uid,
      username: judge.nameAr,
      email: judge.email,
      addressAr: judge.addressAr,
      addressEn: judge.addressEn,
      phone: judge.phone,
      profileImage: judge.profileImage,
    );
  }

  // التحويل من أدمن قاعدة البيانات (DatabaseAdminProfileModel)
  factory UserSettingsModel.fromDatabaseAdmin(DatabaseAdminProfileModel dbAdmin) {
    return UserSettingsModel(
      uid: dbAdmin.uid,
      username: dbAdmin.nameAr,
      email: dbAdmin.email,
      addressAr: dbAdmin.addressAr,
      addressEn: dbAdmin.addressEn,
      phone: dbAdmin.phone,
      profileImage: dbAdmin.profileImage,
    );
  }

  UserSettingsModel copyWith({
    String? uid, String? username, String? email,
    String? addressAr, String? addressEn,
    String? phone, String? profileImage,
  }) {
    return UserSettingsModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      addressAr: addressAr ?? this.addressAr,
      addressEn: addressEn ?? this.addressEn,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'profile': {
        'phone': {'phone1': phone},
        'address': {'ar': addressAr, 'en': addressEn},
        'profile_image': profileImage,
      }
    };
  }
}

// 2. موديل الأدمن المحدث (AdminProfileModel)
class AdminProfileModel {
  final String uid;
  final String email;
  final String nameAr;
  final String nameEn;
  final String jobAr;
  final String jobEn;
  final String phone;
  final String addressAr;
  final String addressEn;
  final String profileImage;
  final bool isActive;

  const AdminProfileModel({
    required this.uid, required this.email, required this.nameAr, required this.nameEn,
    required this.jobAr, required this.jobEn, required this.phone,
    required this.addressAr, required this.addressEn,
    required this.profileImage, this.isActive = true,
  });

  factory AdminProfileModel.fromJson(Map<String, dynamic> json, String id) {
    return AdminProfileModel(
      uid: id,
      email: json['university_email'] ?? '',
      isActive: json['is_active'] ?? true,
      nameAr: json['profile']?['display_name']?['ar'] ?? '',
      nameEn: json['profile']?['display_name']?['en'] ?? '',
      jobAr: json['jop']?['title']?['ar'] ?? '',
      jobEn: json['jop']?['title']?['en'] ?? '',
      phone: json['profile']?['phone']?['phone1'] ?? '',
      addressAr: json['profile']?['address']?['ar'] ?? '',
      addressEn: json['profile']?['address']?['en'] ?? '',
      profileImage: json['profile']?['profile_image'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'university_email': email,
      'role': 'admin',
      'is_active': isActive,
      'profile': {
        'display_name': {'ar': nameAr, 'en': nameEn},
        'phone': {'phone1': phone},
        'address': {'ar': addressAr, 'en': addressEn},
        'profile_image': profileImage,
      },
      'jop': {'title': {'ar': jobAr, 'en': jobEn}},
    };
  }

  AdminProfileModel copyWith({
    String? uid, String? email, String? nameAr, String? nameEn,
    String? jobAr, String? jobEn, String? phone, String? addressAr,
    String? addressEn, String? profileImage, bool? isActive,
  }) {
    return AdminProfileModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      jobAr: jobAr ?? this.jobAr,
      jobEn: jobEn ?? this.jobEn,
      phone: phone ?? this.phone,
      addressAr: addressAr ?? this.addressAr,
      addressEn: addressEn ?? this.addressEn,
      profileImage: profileImage ?? this.profileImage,
      isActive: isActive ?? this.isActive,
    );
  }
}

// 3. موديل المحكم المحدث (JudgeProfileModel)
class JudgeProfileModel {
  final String uid;
  final String email;
  final String nameAr;
  final String nameEn;
  final String jobAr;
  final String jobEn;
  final String phone;
  final String addressAr;
  final String addressEn;
  final String profileImage;
  final bool isActive;

  const JudgeProfileModel({
    required this.uid, required this.email, required this.nameAr, required this.nameEn,
    required this.jobAr, required this.jobEn, required this.phone,
    required this.addressAr, required this.addressEn,
    required this.profileImage, this.isActive = true,
  });

  factory JudgeProfileModel.fromJson(Map<String, dynamic> json, String id) {
    return JudgeProfileModel(
      uid: id,
      email: json['university_email'] ?? '',
      nameAr: json['profile']?['display_name']?['ar'] ?? '',
      nameEn: json['profile']?['display_name']?['en'] ?? '',
      jobAr: json['jop']?['title']?['ar'] ?? '',
      jobEn: json['jop']?['title']?['en'] ?? '',
      phone: json['profile']?['phone']?['phone1'] ?? '',
      addressAr: json['profile']?['address']?['ar'] ?? '',
      addressEn: json['profile']?['address']?['en'] ?? '',
      profileImage: json['profile']?['profile_image'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'university_email': email,
      'role': 'judge',
      'profile': {
        'display_name': {'ar': nameAr, 'en': nameEn},
        'phone': {'phone1': phone},
        'address': {'ar': addressAr, 'en': addressEn},
        'profile_image': profileImage,
      },
      'jop': {'title': {'ar': jobAr, 'en': jobEn}},
      'is_active': isActive,
    };
  }

  JudgeProfileModel copyWith({
    String? uid, String? email, String? nameAr, String? nameEn,
    String? jobAr, String? jobEn, String? phone, String? addressAr,
    String? addressEn, String? profileImage, bool? isActive,
  }) {
    return JudgeProfileModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      jobAr: jobAr ?? this.jobAr,
      jobEn: jobEn ?? this.jobEn,
      phone: phone ?? this.phone,
      addressAr: addressAr ?? this.addressAr,
      addressEn: addressEn ?? this.addressEn,
      profileImage: profileImage ?? this.profileImage,
      isActive: isActive ?? this.isActive,
    );
  }
}