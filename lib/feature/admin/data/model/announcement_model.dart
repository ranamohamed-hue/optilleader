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

  // 1. تحويل البيانات من Map (Firebase) إلى Object (Flutter)
  factory AnnouncementModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return AnnouncementModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'Active',
      // التعامل مع التاريخ القادم من Firebase كـ Timestamp
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

  Color getStatusColor() {
    switch (status) {
      case 'Active':
        return const Color(0xFF2196F3); // Blue
      case 'Pending':
        return Colors.orange.shade700;
      case 'Closed':
        return Colors.redAccent;
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
