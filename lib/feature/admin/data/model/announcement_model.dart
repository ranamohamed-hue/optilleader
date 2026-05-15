import 'package:flutter/material.dart';

class AnnouncementModel {
  String? id;
  String title;
  String description;
  String status;
  DateTime deadline;
  int applicants;
  String? imageUrl;
  DateTime createdAt;

  AnnouncementModel({
    this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.deadline,
    this.applicants = 0,
    this.imageUrl,
    required this.createdAt,
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
      createdAt: (map['createdAt'] != null)
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'deadline': deadline,
      'applicants': applicants,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
    };
  }

  // ✅ [إضافة] قائمة الحالات الممكنة للإعلان (للاستخدام في الـ Dropdown)
  static List<String> get statusList => ['Active', 'Pending', 'Closed'];

  Color getStatusColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case 'Active':
        return Colors.blue;
      case 'Pending':
        return Colors.orange.shade700;
      case 'Closed':
        return colorScheme.error;
      default:
        return Colors.grey;
    }
  }

  AnnouncementModel copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    DateTime? deadline,
    int? applicants,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      applicants: applicants ?? this.applicants,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
