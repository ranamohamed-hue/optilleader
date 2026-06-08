import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';

class ActivityModel {
  final String id;               // ✅ جديد
  final String type;
  final String title;
  final String organization;
  final String date;
  final int? durationHours;
  final String participationType;
  
  // ✅ الحقول للمصداقية
  final VerificationStatus status;
  final String? proofUrl;        
  final String? proofFileType;   // ✅ جديد - "image" أو "pdf"

  ActivityModel({
    required this.id,
    required this.type,
    required this.title,
    required this.organization,
    required this.date,
    this.durationHours,
    required this.participationType,
    this.status = VerificationStatus.pending,
    this.proofUrl,
    this.proofFileType,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      organization: json['organization'] ?? '',
      date: json['date'] ?? '',
      durationHours: json['duration_hours'],
      participationType: json['participation_type'] ?? '',
      status: parseVerificationStatus(json['status']),
      proofUrl: json['proofUrl'],
      proofFileType: json['proofFileType'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'organization': organization,
      'date': date,
      'duration_hours': durationHours,
      'participation_type': participationType,
      'status': status.name,
      'proofUrl': proofUrl,
      'proofFileType': proofFileType,
    };
  }

  ActivityModel copyWith({
    String? id,
    String? type,
    String? title,
    String? organization,
    String? date,
    int? durationHours,
    String? participationType,
    VerificationStatus? status,
    String? proofUrl,
    String? proofFileType,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      organization: organization ?? this.organization,
      date: date ?? this.date,
      durationHours: durationHours ?? this.durationHours,
      participationType: participationType ?? this.participationType,
      status: status ?? this.status,
      proofUrl: proofUrl ?? this.proofUrl,
      proofFileType: proofFileType ?? this.proofFileType,
    );
  }
}