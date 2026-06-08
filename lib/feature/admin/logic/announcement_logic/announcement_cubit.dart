import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/admin/data/repo/announcement_repos/announcement_repo.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart'; 
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart'; 
import 'announcement_state.dart';

class AnnouncementCubit extends Cubit<AnnouncementState> {
  final IAnnouncementRepository _repository;
  final NotificationRepo _notificationRepo; 
  final FirebaseFirestore _firebaseFirestore; 

  AnnouncementCubit(
    this._repository,
    this._notificationRepo,
    this._firebaseFirestore,
  ) : super(AnnouncementInitial());

  void fetchAnnouncements() {
    emit(AnnouncementLoading());
    _repository.getAnnouncements().listen(
      (data) => emit(AnnouncementLoaded(data)),
      onError: (error) => emit(AnnouncementError("ERROR_FETCH_ANNOUNCEMENTS")),
    );
  }
  Future<void> addAnnouncement(AnnouncementModel announcement, {String? imagePath}) async {
    emit(AnnouncementLoading());
    
    // 1. لو فيه صورة، ارفعها الأول
    if (imagePath != null) {
      final uploadResult = await _repository.uploadAnnouncementImage(imagePath);
      String? finalImageUrl;
      uploadResult.fold(
        (error) {
          emit(AnnouncementError(error));
          return; 
        }, 
        (url) => finalImageUrl = url,
      );
      
      if (finalImageUrl != null) {
        announcement = announcement.copyWith(imageUrl: finalImageUrl);
      }
    }

    // 2. احفظ الإعلان في Firestore
    final result = await _repository.addAnnouncement(announcement);
    result.fold(
      (error) => emit(AnnouncementError(error)),
      (generatedId) { 
        emit(AnnouncementActionSuccess("SUCCESS_ADD_ANNOUNCEMENT"));
        
        _broadcastAnnouncementNotification(announcement.copyWith(id: generatedId));
      },
    );
  }

  //  دالة الإشعار الجماعي للإعلانات والمسابقات
  Future<void> _broadcastAnnouncementNotification(AnnouncementModel announcement) async {
    try {
      // 1. جلب كل الـ UIDs بتوع الدكاترة من الفايرستور
      final snapshot = await _firebaseFirestore
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .get();
      
      final doctorUids = snapshot.docs.map((doc) => doc.id).toList();

      if (doctorUids.isEmpty) return; // مفيش دكاترة نبعتهم

      // 2. تحديد نوع الإشعار
      NotificationType type = NotificationType.announcementCreated;

      // 3. بناء الإشعار
      final notification = AppNotificationModel(
        id: '',
        title: 'إعلان جديد: ${announcement.title}', 
        message: announcement.description ?? 'تم نشر إعلان جديد يرجى المتابعة', 
        type: type,
        timestamp: Timestamp.now(),
        receiverId: '', 
        relatedId: announcement.id, 
      );

      // 4. إرسال الإشعار الجماعي
      await _notificationRepo.broadcastNotification(doctorUids, notification);
      
    } catch (e) {
      print("فشل إرسال إشعار الإعلان: $e");
    }
  }
  
  Future<void> updateAnnouncement(AnnouncementModel announcement, {String? imagePath}) async {
    emit(AnnouncementLoading());
    
    if (imagePath != null) {
      final uploadResult = await _repository.uploadAnnouncementImage(imagePath);
      String? finalImageUrl;
      uploadResult.fold(
        (error) {
          emit(AnnouncementError(error));
          return;
        }, 
        (url) => finalImageUrl = url,
      );
      
      if (finalImageUrl != null) {
        announcement = announcement.copyWith(imageUrl: finalImageUrl);
      }
    }

    final result = await _repository.updateAnnouncement(announcement);
    result.fold(
      (error) => emit(AnnouncementError(error)),
      (_) => emit(AnnouncementActionSuccess("SUCCESS_UPDATE_ANNOUNCEMENT")),
    );
  }

  Future<void> deleteAnnouncement(String id, String? imageUrl) async {
    final result = await _repository.deleteAnnouncement(id, imageUrl);
    result.fold(
      (error) => emit(AnnouncementError(error)),
      (_) => emit(AnnouncementActionSuccess("SUCCESS_DELETE_ANNOUNCEMENT")),
    );
  }

 
}