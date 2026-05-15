import 'package:optialeader/feature/database_admin/data/models/database_admin_model.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/database_admin/data/models/judge_profile_model.dart';
import 'package:optialeader/feature/database_admin/data/models/admin_profile_model.dart'; // تأكد من استيراد الـ Admin model

class UserSettingsModel {
  final String uid;
  final String nameAr; // ✅ تم الاستبدال
  final String nameEn; // ✅ تم الاستبدال
  final String email;
  final String addressAr;
  final String addressEn;
  final String phone;
  final String profileImage;

  UserSettingsModel({
    required this.uid,
    required this.nameAr,
    required this.nameEn,
    required this.email,
    required this.addressAr,
    required this.addressEn,
    required this.phone,
    required this.profileImage,
  });

  // ✅ تصحيح طريقة القراءة من Firestore لتتوافق مع الـ Nested Map
  factory UserSettingsModel.fromFirestore(
    Map<String, dynamic> json,
    String documentId,
  ) {
    return UserSettingsModel(
      uid: documentId,
      nameAr: json['profile']?['display_name']?['ar'] ?? '',
      nameEn: json['profile']?['display_name']?['en'] ?? '',
      email: json['university_email'] ?? '',
      addressAr: json['profile']?['address']?['ar'] ?? '',
      addressEn: json['profile']?['address']?['en'] ?? '',
      phone: json['profile']?['phone']?['phone1'] ?? '',
      profileImage: json['profile']?['profile_image'] ?? '',
    );
  }

  // التحويل من أدمن (AdminProfileModel)
  factory UserSettingsModel.fromAdmin(AdminProfileModel admin) {
    return UserSettingsModel(
      uid: admin.uid,
      nameAr: admin.nameAr, // ✅
      nameEn: admin.nameEn, // ✅
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
      nameAr: doctor.nameAr, // ✅
      nameEn: doctor.nameEn, // ✅
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
      nameAr: judge.nameAr, // ✅
      nameEn: judge.nameEn, // ✅
      email: judge.email,
      addressAr: judge.addressAr,
      addressEn: judge.addressEn,
      phone: judge.phone,
      profileImage: judge.profileImage,
    );
  }

  // التحويل من أدمن قاعدة البيانات (DatabaseAdminProfileModel)
  factory UserSettingsModel.fromDatabaseAdmin(
    DatabaseAdminProfileModel dbAdmin,
  ) {
    return UserSettingsModel(
      uid: dbAdmin.uid,
      nameAr: dbAdmin.nameAr, // ✅
      nameEn: dbAdmin.nameEn, // ✅
      email: dbAdmin.email,
      addressAr: dbAdmin.addressAr,
      addressEn: dbAdmin.addressEn,
      phone: dbAdmin.phone,
      profileImage: dbAdmin.profileImage,
    );
  }

  UserSettingsModel copyWith({
    String? uid,
    String? nameAr,
    String? nameEn,
    String? email,
    String? addressAr,
    String? addressEn,
    String? phone,
    String? profileImage,
  }) {
    return UserSettingsModel(
      uid: uid ?? this.uid,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
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
      },
    };
  }
}
