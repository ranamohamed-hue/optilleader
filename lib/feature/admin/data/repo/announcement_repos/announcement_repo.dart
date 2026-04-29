import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';

class AnnouncementRepository {
  // اسم الكوليكشن في Firestore
  final CollectionReference _collection = FirebaseFirestore.instance.collection(
    'announcements',
  );

  // 1. إضافة إعلان جديد
  Future<void> addAnnouncement(AnnouncementModel announcement) async {
    try {
      await _collection.add(announcement.toMap());
    } catch (e) {
      throw Exception("خطأ أثناء إضافة الإعلان: $e");
    }
  }

  // 2. جلب الإعلانات (Stream) عشان التحديث اللحظي
  Stream<List<AnnouncementModel>> getAnnouncements() {
    return _collection
        .orderBy('createdAt', descending: true) // الأحدث أولاً
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return AnnouncementModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  // 3. تعديل إعلان موجود
  Future<void> updateAnnouncement(AnnouncementModel announcement) async {
    try {
      if (announcement.id != null) {
        await _collection.doc(announcement.id).update(announcement.toMap());
      }
    } catch (e) {
      throw Exception("خطأ أثناء تعديل الإعلان: $e");
    }
  }

  // 4. حذف إعلان
  Future<void> deleteAnnouncement(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw Exception("خطأ أثناء حذف الإعلان: $e");
    }
  }
}
