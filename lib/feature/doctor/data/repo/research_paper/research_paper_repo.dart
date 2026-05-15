import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/doctor/data/model/research_paper_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';

abstract class ResearchRepo {
  /// إضافة بحث جديد (رفع الصورة + حفظ البيانات)
  Future<Either<String, Unit>> addResearchPaper(String doctorUid, ResearchPaperModel paper, File imageFile);
  
  /// حذف بحث معين
  Future<Either<String, Unit>> deleteResearchPaper(String doctorUid, String paperId);
  
  /// تحديث حالة الاعتماد (للأدمن)
  Future<Either<String, Unit>> updatePaperStatus(
    String doctorUid, 
    String paperId, 
    VerificationStatus status, {
    String? rejectionReason,
  });
}