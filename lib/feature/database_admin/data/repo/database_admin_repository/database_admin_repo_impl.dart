import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:optialeader/feature/database_admin/data/models/database_admin_model.dart';
import 'package:optialeader/feature/database_admin/data/repo/database_admin_repository/database_admin_repo.dart';
import 'package:dartz/dartz.dart';
class DatabaseAdminRepoImpl implements DatabaseAdminRepo{
  final FirebaseFirestore _firestore;
  DatabaseAdminRepoImpl(this._firestore);
@override
Future<Either<String,DatabaseAdminProfileModel>>getAdminProfile(String uid)async{
  try {
    final doc=await _firestore.collection('users').doc(uid).get();
    if(doc.exists && doc.data() != null){
      final model=DatabaseAdminProfileModel.fromFirestore(doc.data()!,doc.id);
return Right(model);  
  }
  else{
    return const Left("لم يتم العثور على بيانات الحساب"); 
  }
  }
  on FirebaseException catch(e){
    return Left("خطأ في Firestore: ${e.message}"); 
  }
   catch (e) {
    return Left("حدث خطأ غير متوقع: ${e.toString()}");
  }
}
@override
Future<Either<String, Unit>> updateAdminInfo({
  required String uid,
    required String newPhone,
    required String addressAr,
    required String addressEn,
  })async{
    try {
      await _firestore.collection('users').doc(uid).update({
        'phone': newPhone,
        'address': {
          'ar': addressAr,
          'en': addressEn,
        },
      });
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left("فشل التحديث: ${e.message}");
    } catch (e) {
      return Left(e.toString());
    }
  }
  @override
  Future<Either<String, Unit>> updateProfileImage(String uid, String imageUrl) async {
    try {
      await _firestore.collection('users').doc(uid).update({'profile_image': imageUrl,});
      return const Right(unit);
    } 
    on FirebaseException catch (e) {
      return Left("فشل تحديث الصورة: ${e.message}");}catch (e) {
      return Left(e.toString());
    }
  }
}