import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'package:optialeader/core/helper/file_halper.dart';
import 'package:optialeader/feature/doctor/data/model/activities_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';
import 'package:optialeader/feature/doctor/data/repo/activities/activity_repo.dart';

class ActivityRepoImpl extends ActivityRepo {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client; 
  
  CollectionReference get _usersCollection =>
      firebaseFirestore.collection('users');

  Future<({String url, String fileType})> _uploadFileToSupabase(File file, String doctorUid, String folderName) async {
    final fileType = FileHelper.getFileType(file);
    final extension = FileHelper.getExtension(file);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
    final storagePath = '$folderName/$doctorUid/${DateTime.now().millisecondsSinceEpoch}.$extension';
    
    final fileBytes = await file.readAsBytes();
    
    await _supabase.storage.from('files').uploadBinary(storagePath, fileBytes, fileOptions: const FileOptions(upsert: true));
    final url = _supabase.storage.from('files').getPublicUrl(storagePath);
    
    return (url: url, fileType: fileType == UploadedFileType.image ? 'image' : 'pdf');
  }

  @override
  Future<Either<String, Unit>> addActivity({required String doctorUid, required ActivityModel activity, File? proofFile}) async {
    try {
      String? proofUrl;
      String? proofFileType;

      if (proofFile != null) {
        final upload = await _uploadFileToSupabase(proofFile, doctorUid, 'activities');
        proofUrl = upload.url;
        proofFileType = upload.fileType;
      }

      final activityWithProof = activity.copyWith(proofUrl: proofUrl, proofFileType: proofFileType);

      await _usersCollection.doc(doctorUid).update({
        'scientific_work.other_activities': FieldValue.arrayUnion([activityWithProof.toMap()]),
      });

      return right(unit);
    } catch (e) {
      return left("فشل إضافة النشاط: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, Unit>> deleteActivity(String doctorUid, String activityId) async {
    try {
      final docRef = _usersCollection.doc(doctorUid);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final List<dynamic> activities = List.from(data['scientific_work']?['other_activities'] ?? []);

        final activityToDelete = activities.cast<Map<String, dynamic>?>().firstWhere(
          (a) => a?['id'] == activityId,
          orElse: () => null,
        );
        
        if (activityToDelete != null && activityToDelete['proofUrl'] != null) {
          try {
            final uri = Uri.parse(activityToDelete['proofUrl']);
            final filePath = uri.pathSegments.sublist(uri.pathSegments.indexOf('files') + 1).join('/');
            await _supabase.storage.from('files').remove([filePath]);
          } catch (_) {}
        }

        activities.removeWhere((a) => a['id'] == activityId);
        await docRef.update({'scientific_work.other_activities': activities});
      }
      return right(unit);
    } catch (e) {
      return left("فشل حذف النشاط: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, Unit>> updateActivityStatus(String doctorUid, String activityId, VerificationStatus status, {String? rejectionReason}) async {
    try {
      final docRef = _usersCollection.doc(doctorUid);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final List<dynamic> activities = List.from(data['scientific_work']?['other_activities'] ?? []);

        for (int i = 0; i < activities.length; i++) {
          if (activities[i]['id'] == activityId) {
            activities[i]['status'] = status.name;
            if (rejectionReason != null) { activities[i]['rejectionReason'] = rejectionReason; } 
            else { activities[i].remove('rejectionReason'); }
            break;
          }
        }
        await docRef.update({'scientific_work.other_activities': activities});
      }
      return right(unit);
    } catch (e) {
      return left("فشل تحديث حالة النشاط: ${e.toString()}");
    }
  }
}