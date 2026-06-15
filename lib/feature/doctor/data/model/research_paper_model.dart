import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';

class ResearchPaperModel {
  final String id;
  
  // 1. البيانات الأساسية
  final String titleAr;
  final String titleEn;
  final String journalName;
  final String issn;
  final String impactFactor;
  final int publicationYear;
  final int authorOrder;
  final int totalAuthors;
  final String? doi;

  final int authorsInSameSpecialty;  // عدد الباحثين في نفس التخصص العام
  final bool isTopTierJournal;       // هل المجلة حاصلة على 10 نقاط (Top Tier)؟

  // 2. تصنيف المجلة
  final JournalScope journalScope;
  final JournalLevel journalLevel;
  final IndexingDatabase indexingDatabase;
  final String journalUrl;

  // 3. الإثباتات والمصداقية
  final String paperFileUrl;       
  final String paperFileType;      
  final String? indexingProofUrl;  
  final String? indexingProofType; 

  // 4. حالة الاعتماد
  final VerificationStatus status;
  final String? rejectionReason;

  ResearchPaperModel({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.journalName,
    required this.issn,
    required this.impactFactor,
    required this.publicationYear,
    required this.authorOrder,
    required this.totalAuthors,
    this.doi,
    this.authorsInSameSpecialty = 1,
    this.isTopTierJournal = false,   
    required this.journalScope,
    required this.journalLevel,
    required this.indexingDatabase,
    required this.journalUrl,
    required this.paperFileUrl,
    this.paperFileType = 'image',
    this.indexingProofUrl,
    this.indexingProofType,
    this.status = VerificationStatus.pending,
    this.rejectionReason,
  });

  factory ResearchPaperModel.fromJson(Map<String, dynamic> json) {
    return ResearchPaperModel(
      id: json['id'] ?? '',
      titleAr: json['titleAr'] ?? '',
      titleEn: json['titleEn'] ?? '',
      journalName: json['journalName'] ?? '',
      issn: json['issn'] ?? '',
      impactFactor: json['impactFactor'] ?? '',
      publicationYear: json['publicationYear'] ?? 0,
      authorOrder: json['authorOrder'] ?? 0,
      totalAuthors: json['totalAuthors'] ?? 0,
      doi: json['doi'],
      authorsInSameSpecialty: json['authors_in_same_specialty'] ?? 1,
      isTopTierJournal: json['is_top_tier_journal'] ?? false,
      journalScope: enumFromString(JournalScope.values, json['journalScope']),
      journalLevel: enumFromString(JournalLevel.values, json['journalLevel']),
      indexingDatabase: enumFromString(IndexingDatabase.values, json['indexingDatabase']),
      journalUrl: json['journalUrl'] ?? '',
      paperFileUrl: json['paperFileUrl'] ?? '',
      paperFileType: json['paperFileType'] ?? 'image',
      indexingProofUrl: json['indexingProofUrl'],
      indexingProofType: json['indexingProofType'],
      status: parseVerificationStatus(json['status']),
      rejectionReason: json['rejectionReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titleAr': titleAr,
      'titleEn': titleEn,
      'journalName': journalName,
      'issn': issn,
      'impactFactor': impactFactor,
      'publicationYear': publicationYear,
      'authorOrder': authorOrder,
      'totalAuthors': totalAuthors,
      'doi': doi,
      'authors_in_same_specialty': authorsInSameSpecialty,
      'is_top_tier_journal': isTopTierJournal,
      'journalScope': journalScope.name,
      'journalLevel': journalLevel.name,
      'indexingDatabase': indexingDatabase.name,
      'journalUrl': journalUrl,
      'paperFileUrl': paperFileUrl,
      'paperFileType': paperFileType,
      'indexingProofUrl': indexingProofUrl,
      'indexingProofType': indexingProofType,
      'status': status.name,
      'rejectionReason': rejectionReason,
    };
  }

  ResearchPaperModel copyWith({
    String? id,
    String? titleAr,
    String? titleEn,
    String? journalName,
    String? issn,
    String? impactFactor,
    int? publicationYear,
    int? authorOrder,
    int? totalAuthors,
    String? doi,
    int? authorsInSameSpecialty, 
    bool? isTopTierJournal,    
    JournalScope? journalScope,
    JournalLevel? journalLevel,
    IndexingDatabase? indexingDatabase,
    String? journalUrl,
    String? paperFileUrl,
    String? paperFileType,
    String? indexingProofUrl,
    String? indexingProofType,
    VerificationStatus? status,
    String? rejectionReason,
  }) {
    return ResearchPaperModel(
      id: id ?? this.id,
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      journalName: journalName ?? this.journalName,
      issn: issn ?? this.issn,
      impactFactor: impactFactor ?? this.impactFactor,
      publicationYear: publicationYear ?? this.publicationYear,
      authorOrder: authorOrder ?? this.authorOrder,
      totalAuthors: totalAuthors ?? this.totalAuthors,
      doi: doi ?? this.doi,
      authorsInSameSpecialty: authorsInSameSpecialty ?? this.authorsInSameSpecialty,
      isTopTierJournal: isTopTierJournal ?? this.isTopTierJournal,
      journalScope: journalScope ?? this.journalScope,
      journalLevel: journalLevel ?? this.journalLevel,
      indexingDatabase: indexingDatabase ?? this.indexingDatabase,
      journalUrl: journalUrl ?? this.journalUrl,
      paperFileUrl: paperFileUrl ?? this.paperFileUrl,
      paperFileType: paperFileType ?? this.paperFileType,
      indexingProofUrl: indexingProofUrl ?? this.indexingProofUrl,
      indexingProofType: indexingProofType ?? this.indexingProofType,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}