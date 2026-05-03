class AdminProfileModel {
  final String uid;
  final String email;
  final String nameAr;
  final String nameEn;
  final String jobAr;
  final String jobEn;
  final String phone;
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
      profileImage: json['profile']?['profile_image'] ?? '',
    );
  }

  AdminProfileModel copyWith({bool? isActive}) {
    return AdminProfileModel(
      uid: this.uid,
      email: this.email,
      nameAr: this.nameAr,
      nameEn: this.nameEn,
      jobAr: this.jobAr,
      jobEn: this.jobEn,
      phone: this.phone,
      profileImage: this.profileImage,
      isActive: isActive ?? this.isActive,
    );
  }
}
