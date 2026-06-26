import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:optialeader/feature/admin/data/model/nomination_request_model.dart';
import 'package:optialeader/feature/admin/data/repo/nomination_request/nomination_request_repo.dart';

class NominationRequestRepositoryImpl implements NominationRequestRepository {
  final FirebaseFirestore _firestore;
  final SupabaseClient _supabase; // ✅ Supabase لرفع الملفات

  NominationRequestRepositoryImpl(this._firestore, this._supabase);

  @override
  Future<Either<String, String>> uploadDeclarationFile(String filePath) async {
    try {
      final File file = File(filePath);

      // استخراج امتداد الملف
      final String extension = filePath.split('.').last;

      // إنشاء اسم فريد للملف
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}.$extension';
      final String storagePath = 'declarations/$fileName';

      // ✅ رفع الملف على البوكيت المسمى 'files' في Supabase
      await _supabase.storage.from('files').upload(
            storagePath,
            file,
            fileOptions: const FileOptions(upsert: false),
          );

      // ✅ الحصول على الرابط العام للملف
      final String publicUrl = _supabase.storage.from('files').getPublicUrl(storagePath);

      return Right(publicUrl);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, String>> submitRequest(
    NominationRequestModel request,
  ) async {
    try {
      // حفظ البيانات في Firestore
      final docRef = await _firestore.collection('nomination_requests').add(request.toMap());

      // ✅ برجع الـ ID اللي اتولد من Firestore عشان الـ Cubit يستخدمه في الإشعارات
      return Right(docRef.id);
    } catch (e) {
      print("🔴 FIRESTORE SUBMIT ERROR: $e");
      return Left(e.toString());
    }
  }

  @override
  Stream<List<NominationRequestModel>> getAdminRequests({
    required String status,
  }) {
    return _firestore
        .collection('nomination_requests')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NominationRequestModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  @override
  Stream<List<NominationRequestModel>> getEvaluatorRequests(
    String evaluatorId,
  ) {
    return _firestore
        .collection('nomination_requests')
        .where('evaluatorId', isEqualTo: evaluatorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NominationRequestModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  @override
  Future<Either<String, Unit>> updateRequest(
    NominationRequestModel request,
  ) async {
    try {
      await _firestore.collection('nomination_requests').doc(request.id).update(request.toMap());
      return const Right(unit); // ✅ التحديث اتعمل بنجاح
    } catch (e) {
      return Left(e.toString());
    }
  }

  // ✅ دالة جلب المحكمين من كولكشن الـ users
  @override
  Future<Either<String, List<Map<String, dynamic>>>> getEvaluators() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'evaluator') // تأكدي إن حقل الرول اسمه 'role'
          .get();

      final evaluators = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // إضافة الـ ID للـ Map
        return data;
      }).toList();

      return Right(evaluators);
    } catch (e) {
      print("🔴 FIRESTORE GET EVALUATORS ERROR: $e");
      return Left(e.toString());
    }
  }
}