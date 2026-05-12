class DatabaseAdminProfileModel {
  final String uid;
  final String nameAr;  
  final String nameEn;  
  final String email;
  final String addressAr;  
  final String addressEn; 
  final String profileImage;
  final String role;
  final String phone;
  final String national_id;
  final String employee_id;
  final bool isFirstLogin;

  const DatabaseAdminProfileModel({
    required this.uid,
    required this.nameAr,
    required this.nameEn,
    required this.email,
    required this.addressAr,
    required this.addressEn,
    required this.profileImage,
    this.role = 'database_admin',
    required this.phone,
    required this.national_id,
    required this.employee_id,
    this.isFirstLogin = true,
  });

  factory DatabaseAdminProfileModel.fromFirestore(Map<String, dynamic> json, String id) {
    return DatabaseAdminProfileModel(
      uid: id,
      nameAr: json['display_name']?['ar'] ?? json['username_ar'] ?? '',
      nameEn: json['display_name']?['en'] ?? json['username_en'] ?? '',
      email: json['university_email'] ?? '',
      addressAr: json['address']?['ar'] ?? '',
      addressEn: json['address']?['en'] ?? '',
      profileImage: json['profile_image_url'] ?? '',
      role: json['role'] ?? 'database_admin',
      phone: json['phone'] ?? '',
      national_id: json['national_id'] ?? '',
      employee_id: json['employee_id'] ?? '',
      isFirstLogin: json['isFirstLogin'] ?? true, 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'display_name': {
        'ar': nameAr,
        'en': nameEn,
      },
      'university_email': email,
      'address': {
        'ar': addressAr,
        'en': addressEn,
      },
      'profile_image': profileImage,
      'role': role,
      'phone': phone,
      'national_id': national_id,
      'employee_id': employee_id,
      'isFirstLogin': isFirstLogin, 
    };
  }

  DatabaseAdminProfileModel copyWith({
    String? uid,
    String? nameAr,
    String? nameEn,
    String? email,
    String? addressAr,
    String? addressEn,
    String? profileImage,
    String? role,
    String? phone,
    String? national_id,
    String? employee_id,
    bool? isFirstLogin, 
  }) {
    return DatabaseAdminProfileModel(
      uid: uid ?? this.uid,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      email: email ?? this.email,
      addressAr: addressAr ?? this.addressAr,
      addressEn: addressEn ?? this.addressEn,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      national_id: national_id ?? this.national_id,
      employee_id: employee_id ?? this.employee_id,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin, 
    );
  }
}