import 'package:equatable/equatable.dart';

class AdminInfoModel extends Equatable {
  final Map<String, dynamic> displayName;
  final Map<String, dynamic> jobTitle;
  final Map<String, dynamic> address;
  final Map<String, dynamic> phone;
  final String profileImage;
  final String nationalId;
  final String employeeId;

  const AdminInfoModel({
    required this.displayName,
    required this.jobTitle,
    required this.address,
    required this.phone,
    required this.profileImage,
    required this.nationalId,
    required this.employeeId,
  });
  factory AdminInfoModel.fromFirestore(Map<String, dynamic> data) {
    final profile = Map<String, dynamic>.from(data['profile'] ?? {});
    final job = Map<String, dynamic>.from(data['jop'] ?? {});

    return AdminInfoModel(
      displayName: Map<String, dynamic>.from(profile['display_name'] ?? {}),
      address: Map<String, dynamic>.from(profile['address'] ?? {}),
      phone: Map<String, dynamic>.from(profile['phone'] ?? {}),
      profileImage: profile['profile_image'] as String? ?? '',
      jobTitle: Map<String, dynamic>.from(job['title'] ?? {}),
      nationalId: data['national_id'] as String? ?? '',
      employeeId: data['employee_id'] as String? ?? '',
    );
  }

  /// ================= GETTERS =================

  String get displayNameAr => displayName['ar'] ?? '';
  String get displayNameEn => displayName['en'] ?? '';

  String get jobTitleAr => jobTitle['ar'] ?? '';
  String get jobTitleEn => jobTitle['en'] ?? '';

  String get addressAr => address['ar'] ?? '';
  String get addressEn => address['en'] ?? '';

  String get phone1 => phone['phone1'] ?? '';
  String get phone2 => phone['phone2'] ?? '';

  /// 🔥 dynamic حسب اللغة
  String getDisplayName(String locale) => displayName[locale] ?? '';
  String getJobTitle(String locale) => jobTitle[locale] ?? '';
  String getAddress(String locale) => address[locale] ?? '';

  @override
  List<Object?> get props => [
    displayName,
    jobTitle,
    address,
    phone,
    profileImage,
    nationalId,
    employeeId,
  ];
}
