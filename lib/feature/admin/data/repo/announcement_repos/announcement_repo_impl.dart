import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';

// تعريف الـ Interface (عشان لو حبيتي تعملي Unit Testing بعدين)
abstract class IAnnouncementRepository {
  Future<void> addAnnouncement(AnnouncementModel announcement);
  Stream<List<AnnouncementModel>> getAnnouncements();
  Future<void> updateAnnouncement(AnnouncementModel announcement);
  Future<void> deleteAnnouncement(String id);
}

class AnnouncementRepositoryImpl implements IAnnouncementRepository {
  final FirebaseFirestore _firestore;

  // Constructor بياخد instance من الفايربيز
  AnnouncementRepositoryImpl(this._firestore);

  // الكوليكشن الأساسي
  CollectionReference get _collection => _firestore.collection('announcements');

  @override
  Future<void> addAnnouncement(AnnouncementModel announcement) async {
    try {
      await _collection.add(announcement.toMap());
    } catch (e) {
      throw Exception("فشل في إضافة الإعلان: $e");
    }
  }

  @override
  Stream<List<AnnouncementModel>> getAnnouncements() {
    return _collection.orderBy('createdAt', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return AnnouncementModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  @override
  Future<void> updateAnnouncement(AnnouncementModel announcement) async {
    try {
      if (announcement.id != null) {
        await _collection.doc(announcement.id).update(announcement.toMap());
      } else {
        throw Exception("ID الإعلان غير موجود");
      }
    } catch (e) {
      throw Exception("فشل في تحديث الإعلان: $e");
    }
  }

  @override
  Future<void> deleteAnnouncement(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw Exception("فشل في حذف الإعلان: $e");
    }
  }
}
