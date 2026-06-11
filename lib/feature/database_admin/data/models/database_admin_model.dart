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

   factory DatabaseAdminProfileModel.fromFirestore(
    Map<String, dynamic> json,
    String id,
  ) {
    final profile = json['profile'] as Map<String, dynamic>? ?? {};

    return DatabaseAdminProfileModel(
      uid: id,
      nameAr: profile['display_name']?['ar'] ?? '',
      nameEn: profile['display_name']?['en'] ?? '',
      email: json['university_email'] ?? '',
      addressAr: profile['address']?['ar'] ?? '',
      addressEn: profile['address']?['en'] ?? '',
      profileImage: profile['profile_image'] ?? '',
      role: json['role'] ?? 'database_admin',
      phone: profile['phone']?['phone1'] ?? '',
      // ✅ التعديل هنا: القراءة من جوه profile
      national_id: profile['national_id'] ?? json['national_id'] ?? '',
      employee_id: profile['employee_id'] ?? json['employee_id'] ?? '',
      isFirstLogin: json['isFirstLogin'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'university_email': email,
      'isFirstLogin': isFirstLogin,
      // ✅ الكتابة موحدة جوه ماب profile
      'profile': {
        'display_name': {'ar': nameAr, 'en': nameEn},
        'phone': {'phone1': phone},
        'address': {'ar': addressAr, 'en': addressEn},
        'profile_image': profileImage,
        'national_id': national_id, // ✅ التعديل هنا: الكتابة جوه profile
        'employee_id': employee_id, // ✅ التعديل هنا: الكتابة جوه profile
      },
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
