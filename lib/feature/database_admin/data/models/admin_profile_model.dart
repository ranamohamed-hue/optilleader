import 'package:flutter/material.dart';

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
    required this.uid,
    required this.email,
    required this.nameAr,
    required this.nameEn,
    required this.jobAr,
    required this.jobEn,
    required this.phone,
    required this.addressAr,
    required this.addressEn,
    required this.profileImage,
    this.isActive = true,
  });

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
      'jop': {
        'title': {'ar': jobAr, 'en': jobEn},
      },
    };
  }

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

  AdminProfileModel copyWith({
    String? uid,
    String? email,
    String? nameAr,
    String? nameEn,
    String? jobAr,
    String? jobEn,
    String? phone,
    String? addressAr,
    String? addressEn,
    String? profileImage,
    bool? isActive,
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
