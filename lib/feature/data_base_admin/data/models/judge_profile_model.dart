class JudgeProfileModel {
  final String uid;
  final String email;
  final String nameAr;
  final String nameEn;
  final String jobAr;
  final String jobEn;
  final String phone;
  final String profileImage;
  final bool isActive;
  const JudgeProfileModel({
    required this.uid,
    required this.email,
    required this.nameAr,
    required this.nameEn,
    required this.jobAr,
    required this.jobEn,
    required this.phone,
    required this.profileImage,
    this.isActive=true
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
        'profile_image': profileImage,
      },
      'jop': {
        'title': {'ar': jobAr, 'en': jobEn},
      },
      'is_active': isActive,
    };
  }
}
