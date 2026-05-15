import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';

class ActivityModel {
  final String type; 
  final String title;
  final String organization;
  final String date; 
  final int? durationHours; 
  final String participationType; 
  
  // ✅ الحقول الجديدة للمصداقية
  final VerificationStatus status;
  final String? proofUrl; // رابط شهادة إتمام الدورة أو المؤتمر

  ActivityModel({
    required this.type,
    required this.title,
    required this.organization,
    required this.date,
    this.durationHours,
    required this.participationType,
    this.status = VerificationStatus.pending, // افتراضياً قيد المراجعة
    this.proofUrl,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      organization: json['organization'] ?? '',
      date: json['date'] ?? '',
      durationHours: json['duration_hours'],
      participationType: json['participation_type'] ?? '',
      status: parseVerificationStatus(json['status']), // ✅
      proofUrl: json['proofUrl'], // ✅
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'organization': organization,
      'date': date,
      'duration_hours': durationHours,
      'participation_type': participationType,
      'status': status.name, // ✅
      'proofUrl': proofUrl, // ✅
    };
  }

  ActivityModel copyWith({
    String? type,
    String? title,
    String? organization,
    String? date,
    int? durationHours,
    String? participationType,
    VerificationStatus? status, // ✅
    String? proofUrl, // ✅
  }) {
    return ActivityModel(
      type: type ?? this.type,
      title: title ?? this.title,
      organization: organization ?? this.organization,
      date: date ?? this.date,
      durationHours: durationHours ?? this.durationHours,
      participationType: participationType ?? this.participationType,
      status: status ?? this.status,
      proofUrl: proofUrl ?? this.proofUrl,
    );
  }
}