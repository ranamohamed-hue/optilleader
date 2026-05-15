import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:optialeader/feature/doctor/data/model/research_paper_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';
import 'package:optialeader/feature/doctor/data/repo/research_paper/research_paper_repo.dart';

class ResearchRepoImpl extends ResearchRepo {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  CollectionReference get _usersCollection =>
      firebaseFirestore.collection('users');

  @override
  Future<Either<String, Unit>> addResearchPaper(
    String doctorUid, 
    ResearchPaperModel paper, 
    File imageFile,
  ) async {
    try {
      // 1. رفع صورة الصفحة الأولى للبحث
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = firebaseStorage.ref().child('research_papers/$doctorUid/$fileName');
      await ref.putFile(imageFile);
      final String imageUrl = await ref.getDownloadURL();

      // 2. تحديث الموديل بالـ URL الحقيقي
      final paperWithImage = paper.copyWith(paperImageUrl: imageUrl);

      // 3. إضافة البحث للـ Array في الفايرستور باستخدام FieldValue.arrayUnion
      // ملحوظة: arrayUnion بيمنع التكرار لو الـ Object متطابق 100%
      await _usersCollection.doc(doctorUid).update({
        'scientific_work.research_papers': FieldValue.arrayUnion([paperWithImage.toMap()]),
      });

      return right(unit);
    } catch (e) {
      return left("فشل إضافة البحث: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, Unit>> deleteResearchPaper(
    String doctorUid, 
    String paperId,
  ) async {
    try {
      final docRef = _usersCollection.doc(doctorUid);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final List<dynamic> papers = List.from(data['scientific_work']?['research_papers'] ?? []);

        // فلترة الـ Array بحذف البحث اللي ليه الـ ID ده
        papers.removeWhere((paper) => paper['id'] == paperId);

        // حفظ الـ Array الجديدة بعد الحذف
        await docRef.update({
          'scientific_work.research_papers': papers,
        });
      }
      return right(unit);
    } catch (e) {
      return left("فشل حذف البحث: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, Unit>> updatePaperStatus(
    String doctorUid, 
    String paperId, 
    VerificationStatus status, {
    String? rejectionReason,
  }) async {
    try {
      final docRef = _usersCollection.doc(doctorUid);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final List<dynamic> papers = List.from(data['scientific_work']?['research_papers'] ?? []);

        // البحث عن البحث وتعديل الحالة
        for (int i = 0; i < papers.length; i++) {
          if (papers[i]['id'] == paperId) {
            papers[i]['status'] = status.name;
            if (rejectionReason != null) {
              papers[i]['rejectionReason'] = rejectionReason;
            } else {
              papers[i].remove('rejectionReason');
            }
            break;
          }
        }

        // حفظ الـ Array بعد التعديل
        await docRef.update({
          'scientific_work.research_papers': papers,
        });
      }
      return right(unit);
    } catch (e) {
      return left("فشل تحديث حالة البحث: ${e.toString()}");
    }
  }
}