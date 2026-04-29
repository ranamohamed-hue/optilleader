import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:optialeader/feature/admin/data/model/admin_info_model.dart';
import 'package:optialeader/feature/auth/data/models/user_model.dart';

class AdminModel extends Equatable {
  final String uid;
  final String email;
  final String username;
  final UserRole role;
  final bool isFirstLogin;
  final AdminInfoModel info;

  const AdminModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.role,
    required this.isFirstLogin,
    required this.info,
  });

  factory AdminModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return AdminModel(
      uid: doc.id,
      email: data['university_email'] ?? '',
      username: data['username'] ?? '',
      role: _mapRole(data['role']),
      isFirstLogin: data['isFirstLogin'] ?? true,
      info: AdminInfoModel.fromFirestore(data),
    );
  }

  static UserRole _mapRole(String? role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'judge':
        return UserRole.judge;
      default:
        return UserRole.user;
    }
  }

  /// 🔥 لو احتجت تستخدمه كنص
  String get roleString {
    switch (role) {
      case UserRole.admin:
        return 'admin';
      case UserRole.judge:
        return 'judge';
      case UserRole.user:
        return 'user';
    }
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        username,
        role,
        isFirstLogin,
        info,
      ];
}