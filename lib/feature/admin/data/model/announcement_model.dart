import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  String? id;
  String title;
  String description;
  String status;
  DateTime deadline;
  int applicants;
  String? imageUrl;
  String targetRole;
  DateTime createdAt;

  String? collegeId;
  String? collegeName;
  String? departmentId;
  String? departmentName;

  // ✅ تعريف القوائم عشان الـ Dropdowns ما تقعش
  static const List<String> targetRoleList = [
    'general',
    'dean',
    'rector',
    'vice_chancellor',
    'head_department',
    'vice_dean',
    'quality_manager',
    'administrative',
  ];
  static const List<String> statusList = ['Active', 'Pending', 'Closed'];

  AnnouncementModel({
    this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.deadline,
    this.applicants = 0,
    this.imageUrl,
    required this.targetRole,
    required this.createdAt,
    this.collegeId,
    this.collegeName,
    this.departmentId,
    this.departmentName,
  });

  factory AnnouncementModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return AnnouncementModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'Active',
      deadline: (map['deadline'] != null)
          ? (map['deadline'] as dynamic).toDate()
          : DateTime.now(),
      applicants: map['applicants'] ?? 0,
      imageUrl: map['imageUrl'],
      targetRole: map['targetRole'] ?? 'general',
      createdAt: (map['createdAt'] != null)
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
      collegeId: map['collegeId'],
      collegeName: map['collegeName'],
      departmentId: map['departmentId'],
      departmentName: map['departmentName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'deadline': Timestamp.fromDate(deadline),
      'applicants': applicants,
      'imageUrl': imageUrl,
      'targetRole': targetRole,
      'createdAt': Timestamp.fromDate(createdAt),
      'collegeId': collegeId,
      'collegeName': collegeName,
      'departmentId': departmentId,
      'departmentName': departmentName,
    };
  }

  AnnouncementModel copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    DateTime? deadline,
    int? applicants,
    String? imageUrl,
    String? targetRole,
    DateTime? createdAt,
    String? collegeId,
    String? collegeName,
    String? departmentId,
    String? departmentName,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      applicants: applicants ?? this.applicants,
      imageUrl: imageUrl ?? this.imageUrl,
      targetRole: targetRole ?? this.targetRole,
      createdAt: createdAt ?? this.createdAt,
      collegeId: collegeId ?? this.collegeId,
      collegeName: collegeName ?? this.collegeName,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
    );
  }
}
