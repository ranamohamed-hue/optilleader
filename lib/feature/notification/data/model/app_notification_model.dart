import 'package:cloud_firestore/cloud_firestore.dart';

// ✅ أنواع الإشعارات مقسمة حسب الدور والوظيفة
enum NotificationType {
  // 🔵 أدمن القاعدة (Database Admin)
  userLogin,            // ✅ [جديد] تسجيل دخول مستخدم
  userLogout,           // ✅ [جديد] تسجيل خروج مستخدم
  profileDataUpdated,   // تحديث بيانات مستخدم (عنوان/اتصال)
  accountSuspended,     // تعليق حساب

  // 🟢 أدمن عادي (Admin)
  welcomeAdmin,             // رسالة ترحيبية عند أول تسجيل دخول
  announcementCreated,      // إنشاء إعلان جديد
  announcementExpired,      // انتهاء إعلان
  newDoctorRequest,         // طلب جديد من الدكتور
  judgeRequestCompleted,    // المحكم أنهى التحكيم وأرسل الطلب

  // 🟠 دكتور (Doctor)
  welcomeDoctor,            // رسالة ترحيبية
  newCompetition,           // مسابقة جديدة
  competitionResult,        // نتيجة مسابقة
  requestStatusUpdate,      // تحديث حالة الطلب (قبول/رفض)

  // 🟣 محكم (Judge)
  welcomeJudge,             // رسالة ترحيبية
  newArbitrationRequest,    // طلب تحكيم جديد من الأدمن

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
  final String? relatedId; // ID للطلب أو المسابقة (لو فيه)

  AppNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.timestamp,
    this.relatedId,
  });

  // ✅ دالة لتحويل البيانات القادمة من Firestore لكائن
  factory AppNotificationModel.fromFirestore(Map<String, dynamic> json, String docId) {
    return AppNotificationModel(
      id: docId,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: _parseType(json['type'] ?? 'general'),
      isRead: json['is_read'] ?? false,
      timestamp: json['timestamp'] ?? Timestamp.now(),
      relatedId: json['related_id'],
    );
  }

  static NotificationType _parseType(String type) {
    switch (type) {
      // أدمن القاعدة
      case 'userLogin': return NotificationType.userLogin;
      case 'userLogout': return NotificationType.userLogout;
      case 'profileDataUpdated': return NotificationType.profileDataUpdated;
      case 'accountSuspended': return NotificationType.accountSuspended;
      // أدمن عادي
      case 'welcomeAdmin': return NotificationType.welcomeAdmin;
      case 'announcementCreated': return NotificationType.announcementCreated;
      case 'announcementExpired': return NotificationType.announcementExpired;
      case 'newDoctorRequest': return NotificationType.newDoctorRequest;
      case 'judgeRequestCompleted': return NotificationType.judgeRequestCompleted;
      // دكتور
      case 'welcomeDoctor': return NotificationType.welcomeDoctor;
      case 'newCompetition': return NotificationType.newCompetition;
      case 'competitionResult': return NotificationType.competitionResult;
      case 'requestStatusUpdate': return NotificationType.requestStatusUpdate;
      // محكم
      case 'welcomeJudge': return NotificationType.welcomeJudge;
      case 'newArbitrationRequest': return NotificationType.newArbitrationRequest;
      
      default: return NotificationType.general;
    }
  }
}