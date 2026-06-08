import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  //  أدمن القاعدة (Database Admin)
  userLogin,
  userLogout,
  profileDataUpdated,
  accountSuspended,

  //  أدمن عادي (Admin)
  welcomeAdmin,
  announcementCreated,
  announcementExpired,
  newDoctorRequest,
  judgeRequestCompleted,
  
  //  إشعارات الأبحاث والأنشطة
  newResearchSubmitted,      // دكتور رفع بحث جديد
  newActivitySubmitted,      // دكتور رفع نشاط جديد
  researchStatusUpdated,     // أدمن وافق/رفض البحث
  activityStatusUpdated,     // أدمن وافق/رفض النشاط

  //  دكتور (Doctor)
  welcomeDoctor,
  newCompetition,
  competitionResult,
  requestStatusUpdate,

  //  محكم (Judge)
  welcomeJudge,
  newArbitrationRequest,

  // عام
  general,
}

class AppNotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final Timestamp timestamp;
  final String? relatedId;     
  final String receiverId;     
  final String? senderName;    

  AppNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.timestamp,
    this.relatedId,
    required this.receiverId,
    this.senderName,
  });

  factory AppNotificationModel.fromFirestore(Map<String, dynamic> json, String docId) {
    return AppNotificationModel(
      id: docId,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: _parseType(json['type'] ?? 'general'),
      isRead: json['is_read'] ?? false,
      timestamp: json['timestamp'] ?? Timestamp.now(),
      relatedId: json['related_id'],
      receiverId: json['receiver_id'] ?? '', 
      senderName: json['sender_name'],       
    );
  }

  //  دالة لتحويل الموديل لـ Map عشان نحفظه في الفايرستور
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type.name, // بنحفظ الـ Enum كـ String
      'is_read': isRead,
      'timestamp': timestamp,
      'related_id': relatedId,
      'receiver_id': receiverId,
      'sender_name': senderName,
    };
  }

  static NotificationType _parseType(String type) {
    switch (type) {
      case 'userLogin': return NotificationType.userLogin;
      case 'userLogout': return NotificationType.userLogout;
      case 'profileDataUpdated': return NotificationType.profileDataUpdated;
      case 'accountSuspended': return NotificationType.accountSuspended;
      case 'welcomeAdmin': return NotificationType.welcomeAdmin;
      case 'announcementCreated': return NotificationType.announcementCreated;
      case 'announcementExpired': return NotificationType.announcementExpired;
      case 'newDoctorRequest': return NotificationType.newDoctorRequest;
      case 'judgeRequestCompleted': return NotificationType.judgeRequestCompleted;
     
      case 'newResearchSubmitted': return NotificationType.newResearchSubmitted;
      case 'newActivitySubmitted': return NotificationType.newActivitySubmitted;
      case 'researchStatusUpdated': return NotificationType.researchStatusUpdated;
      case 'activityStatusUpdated': return NotificationType.activityStatusUpdated;

      case 'welcomeDoctor': return NotificationType.welcomeDoctor;
      case 'newCompetition': return NotificationType.newCompetition;
      case 'competitionResult': return NotificationType.competitionResult;
      case 'requestStatusUpdate': return NotificationType.requestStatusUpdate;
      case 'welcomeJudge': return NotificationType.welcomeJudge;
      case 'newArbitrationRequest': return NotificationType.newArbitrationRequest;
      
      default: return NotificationType.general;
    }
  }
}