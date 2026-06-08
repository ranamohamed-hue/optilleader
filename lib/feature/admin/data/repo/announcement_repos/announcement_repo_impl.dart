import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // ✅ إضافة Supabase
import 'package:flutter_image_compress/flutter_image_compress.dart'; // ✅ إضافة ضغط الصور
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/admin/data/repo/announcement_repos/announcement_repo.dart';

class AnnouncementRepositoryImpl implements IAnnouncementRepository {
  final FirebaseFirestore _firestore;
  final SupabaseClient _supabase = Supabase.instance.client; // ✅ تعريف Supabase

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
      return const Left("ERROR_ADD_ANNOUNCEMENT");
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

  // ✅ [تعديل] حذف الإعلان مع حذف الصورة من Supabase
  @override
  Future<Either<String, Unit>> deleteAnnouncement(
    String id,
    String? imageUrl,
  ) async {
    try {
      // 1. حذف الصورة من Supabase إذا وجدت
      if (imageUrl != null && imageUrl.contains('supabase.co')) {
        try {
          final uri = Uri.parse(imageUrl);
          final pathSegments = uri.pathSegments;
          final bucketIndex = pathSegments.indexOf('images');

          if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
            final storagePath = pathSegments.sublist(bucketIndex + 1).join('/');
            await _supabase.storage.from('images').remove([storagePath]);
          }
        } catch (storageError) {
          print(
            'Failed to delete announcement image from Supabase: $storageError',
          );
          // نكمل عملية الحذف حتى لو فشل حذف الصورة عشان ما نقفش العملية
        }
      }

      // 2. حذف المستند من Firestore
      await _collection.doc(id).delete();
      return const Right(unit);
    } catch (e) {
      return const Left("ERROR_DELETE_ANNOUNCEMENT");
    }
  }

  // ✅ [إضافة] دالة ضغط ورفع صورة الإعلان
  @override
  Future<Either<String, String>> uploadAnnouncementImage(
    String filePath,
  ) async {
    try {
      final Uint8List? compressedBytes =
          await FlutterImageCompress.compressWithFile(
            filePath,
            minHeight: 800, // الإعلانات ممكن تحتاج حجم أكتر شوية
            minWidth: 800,
            quality: 85,
          );

      if (compressedBytes == null) {
        return const Left("ERROR_IMAGE_COMPRESS_FAILED");
      }

      // ✅ تثبيت الامتداد بـ jpg لأن المكتبة بترجع jpeg دائماً
      final storagePath =
          'announcements/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _supabase.storage
          .from('images')
          .uploadBinary(
            storagePath,
            compressedBytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg', 
            ),
          );

      final imageUrl = _supabase.storage
          .from('images')
          .getPublicUrl(storagePath);
      return Right(imageUrl);
    } catch (e) {
      print(" Supabase Announcement Upload Error: ${e.toString()}");
      return Left("ERROR_IMAGE_UPLOAD_SUPABASE: ${e.toString()}");
    }
  }
}
