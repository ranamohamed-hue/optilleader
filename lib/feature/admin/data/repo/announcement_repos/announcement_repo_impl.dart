import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';

abstract class IAnnouncementRepository {
  Future<Either<String, Unit>> addAnnouncement(AnnouncementModel announcement);
  Stream<List<AnnouncementModel>> getAnnouncements();
  Future<Either<String, Unit>> updateAnnouncement(
    AnnouncementModel announcement,
  );
  Future<Either<String, Unit>> deleteAnnouncement(String id);
}

class AnnouncementRepositoryImpl implements IAnnouncementRepository {
  final FirebaseFirestore _firestore;
  AnnouncementRepositoryImpl(this._firestore);

  CollectionReference get _collection => _firestore.collection('announcements');

  @override
  Future<Either<String, Unit>> addAnnouncement(
    AnnouncementModel announcement,
  ) async {
    try {
      await _collection.add(announcement.toMap());
      return const Right(unit);
    } catch (e) {
      return const Left("ERROR_ADD_ANNOUNCEMENT"); // ✅ استبدال النص العربي
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
  Future<Either<String, Unit>> updateAnnouncement(
    AnnouncementModel announcement,
  ) async {
    try {
      if (announcement.id != null) {
        await _collection.doc(announcement.id).update(announcement.toMap());
        return const Right(unit);
      }
      return const Left("ERROR_ANNOUNCEMENT_NO_ID");
    } catch (e) {
      return const Left("ERROR_UPDATE_ANNOUNCEMENT");
    }
  }

  @override
  Future<Either<String, Unit>> deleteAnnouncement(String id) async {
    try {
      await _collection.doc(id).delete();
      return const Right(unit);
    } catch (e) {
      return const Left("ERROR_DELETE_ANNOUNCEMENT");
    }
  }
}
