import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';

abstract class IAnnouncementRepository {
  Future<Either<String, Unit>> addAnnouncement(AnnouncementModel announcement);
  Stream<List<AnnouncementModel>> getAnnouncements();
  Future<Either<String, Unit>> updateAnnouncement(AnnouncementModel announcement);
  
  // ✅ [تعديل] إضافة imageUrl عشان نقدر نمسح الصورة من Supabase قبل مسح الإعلان
  Future<Either<String, Unit>> deleteAnnouncement(String id, String? imageUrl);
  
  // ✅ [إضافة] دالة رفع صورة الإعلان لـ Supabase
  Future<Either<String, String>> uploadAnnouncementImage(String filePath);
}