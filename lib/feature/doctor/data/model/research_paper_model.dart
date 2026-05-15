

import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';

class ResearchPaperModel {
  final String id; // استخدم uuid أو أي نص فريد
  // 1. البيانات الأساسية للبحث
  final String titleAr;
  final String titleEn;
  
  final String journalName;
  final String issn;
  final String impactFactor; // Q1, Q2, Q3, Q4
  final int publicationYear;
  final int authorOrder;
  final int totalAuthors;
  final String? doi; // ✅ رقم الـ DOI (مهم جداً للأدمن عشان يبحث بيه)

  // 2. تصنيف المجلة
  final JournalScope journalScope;
  final JournalLevel journalLevel;
  final IndexingDatabase indexingDatabase;
  final String journalUrl; // الرابط الإلكتروني للمجلة

  // 3. الإثباتات والمصداقية
  final String paperImageUrl; // ✅ صورة الصفحة الأولى للبحث (إجباري)
  final String? indexingProofUrl; // إثبات تفهرس المجلة (سكرينة من سكوبس مثلاً)

  // 4. حالة الاعتماد
  final VerificationStatus status;
  final String? rejectionReason; // سبب الرفض لو الأدمن رفضه (مفيد للدكتور يعرف إيه المشكلة)

  ResearchPaperModel({required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.journalName,
    required this.issn,
    required this.impactFactor,
    required this.publicationYear,
    required this.authorOrder,
    required this.totalAuthors,
    this.doi,
    required this.journalScope,
    required this.journalLevel,
    required this.indexingDatabase,
    required this.journalUrl,
    required this.paperImageUrl,
    this.indexingProofUrl,
    this.status = VerificationStatus.pending,
    this.rejectionReason,
  });

  factory ResearchPaperModel.fromJson(Map<String, dynamic> json) {
    return ResearchPaperModel(
      id: json['id']??'',
      // بيانات أساسية
      titleAr: json['titleAr'] ?? '',
      titleEn: json['titleEn'] ?? '',
      journalName: json['journalName'] ?? '',
      issn: json['issn'] ?? '',
      impactFactor: json['impactFactor'] ?? '',
      publicationYear: json['publicationYear'] ?? 0,
      authorOrder: json['authorOrder'] ?? 0,
      totalAuthors: json['totalAuthors'] ?? 0,
      doi: json['doi'],
      
      // تصنيف المجلة
      journalScope: enumFromString(JournalScope.values, json['journalScope']),
      journalLevel: enumFromString(JournalLevel.values, json['journalLevel']),
      indexingDatabase: enumFromString(IndexingDatabase.values, json['indexingDatabase']),
      journalUrl: json['journalUrl'] ?? '',
      
      // الإثباتات
      paperImageUrl: json['paperImageUrl'] ?? '',
      indexingProofUrl: json['indexingProofUrl'],
      
      // الاعتماد
      status: parseVerificationStatus(json['status']),
      rejectionReason: json['rejectionReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id':id,
      'titleAr': titleAr,
      'titleEn': titleEn,
      'journalName': journalName,
      'issn': issn,
      'impactFactor': impactFactor,
      'publicationYear': publicationYear,
      'authorOrder': authorOrder,
      'totalAuthors': totalAuthors,
      'doi': doi,
      
      // تحويل الـ Enum إلى نصوص قبل الحفظ في Firebase
      'journalScope': journalScope.name,
      'journalLevel': journalLevel.name,
      'indexingDatabase': indexingDatabase.name,
      'journalUrl': journalUrl,
      
      'paperImageUrl': paperImageUrl,
      'indexingProofUrl': indexingProofUrl,
      
      'status': status.name,
      'rejectionReason': rejectionReason,
    };
  }

  ResearchPaperModel copyWith({
    String?id,
    String? titleAr,
    String? titleEn,
    String? journalName,
    String? issn,
    String? impactFactor,
    int? publicationYear,
    int? authorOrder,
    int? totalAuthors,
    String? doi,
    JournalScope? journalScope,
    JournalLevel? journalLevel,
    IndexingDatabase? indexingDatabase,
    String? journalUrl,
    String? paperImageUrl,
    String? indexingProofUrl,
    VerificationStatus? status,
    String? rejectionReason,
  }) {
    return ResearchPaperModel(
      id: id ??this.id,
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      journalName: journalName ?? this.journalName,
      issn: issn ?? this.issn,
      impactFactor: impactFactor ?? this.impactFactor,
      publicationYear: publicationYear ?? this.publicationYear,
      authorOrder: authorOrder ?? this.authorOrder,
      totalAuthors: totalAuthors ?? this.totalAuthors,
      doi: doi ?? this.doi,
      journalScope: journalScope ?? this.journalScope,
      journalLevel: journalLevel ?? this.journalLevel,
      indexingDatabase: indexingDatabase ?? this.indexingDatabase,
      journalUrl: journalUrl ?? this.journalUrl,
      paperImageUrl: paperImageUrl ?? this.paperImageUrl,
      indexingProofUrl: indexingProofUrl ?? this.indexingProofUrl,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}