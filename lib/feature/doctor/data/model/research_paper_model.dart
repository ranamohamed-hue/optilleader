import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';

// ====== الـ Enums ======
enum JournalScope { specialized, nonSpecialized }
enum JournalLevel { international, local }
enum IndexingDatabase { scopus, webOfScience, local, other }

T enumFromString<T>(Iterable<T> values, String? value) {
  return values.firstWhere(
    (type) => type.toString().split('.').last == value,
    orElse: () => values.first,
  );
}
// =========================

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
  final int authorsInSameSpecialty;
  final bool isTopTierJournal;

  // 2. تصنيف المجلة
  final JournalScope journalScope;
  final JournalLevel journalLevel;
  final IndexingDatabase indexingDatabase;
  final String journalUrl;

  // 3. الحقول الجديدة لحساب نقاط المجلة
  final String? quartile;
  final bool isLocalJournal;
  final Map<String, bool>? localJournalCriteria;

  // 4. التقرير المعتمد
  final String? certifiedReportNumber;
  final String? certifiedReportFileUrl;

  // 5. درجة الأدمن
  final double adminScore;

  // 6. الإثباتات
  final String paperFileUrl;
  final String paperFileType;
  final String? indexingProofUrl;
  final String? indexingProofType;

  // 7. حالة الاعتماد
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
    this.quartile,
    this.isLocalJournal = false,
    this.localJournalCriteria,
    this.certifiedReportNumber,
    this.certifiedReportFileUrl,
    this.adminScore = 0.0,
    required this.paperFileUrl,
    this.paperFileType = 'image',
    this.indexingProofUrl,
    this.indexingProofType,
    this.status = VerificationStatus.pending,
    this.rejectionReason,
  });

  // =============================================================
  // ============== الحسابات الآلية (Getters) ====================
  // =============================================================

  /// ✅ 1. نسبة المشاركة (مادة 22)
  double get participationPercentage {
    if (authorsInSameSpecialty <= 1) return 1.0;

    int order = authorOrder;
    if (order > authorsInSameSpecialty) order = authorsInSameSpecialty;
    if (order < 1) order = 1;

    // الأول أو الأخير دايماً 100%
    if (order == 1 || order == authorsInSameSpecialty) return 1.0;

    switch (authorsInSameSpecialty) {
      case 2: return 0.8;
      case 3: return 0.7;
      case 4: return 0.55;
      case 5: return 0.4;
      default: return 0.25;
    }
  }

  /// ✅ 2. نقاط المجلة الدولية
  double get _internationalJournalPoints {
    final db = indexingDatabase.name.toLowerCase();
    final q = quartile ?? 'no_if';

    if (db == 'webofscience' || db == 'wos') {
      switch (q) {
        case 'q1': return 10.0;
        case 'q2': return 9.0;
        case 'q3': return 8.0;
        case 'q4':
        case 'no_if': return 7.0;
        default: return 0.0;
      }
    } else if (db == 'scopus') {
      switch (q) {
        case 'q1': return 9.5;
        case 'q2': return 8.5;
        case 'q3': return 7.5;
        case 'q4': return 7.0;
        default: return 0.0;
      }
    }
    return 0.0;
  }

  /// ✅ 3. نقاط المجلة المحلية (بحد أقصى 7)
  double get _localJournalPoints {
    if (localJournalCriteria == null) return 0.0;

    const points = {
      "جهة معترف بها": 1.0,
      "منتظمة الإصدار": 1.0,
      "مكشفة في قواعد بيانات": 1.0,
      "محكمة تحكيماً معماً": 1.0,
      "متخصصة": 1.0,
      "نظام إلكتروني": 1.0,
      "موقع إلكتروني كامل": 0.5,
      "علماء متميزون بالتحرير": 0.5,
    };

    double total = 0.0;
    localJournalCriteria!.forEach((key, isSelected) {
      if (isSelected) {
        total += points[key] ?? 0.0;
      }
    });

    return total > 7.0 ? 7.0 : total;
  }

  /// ✅ 4. إجمالي نقاط المجلة
  double get journalPoints {
    if (isLocalJournal) return _localJournalPoints;
    
    final db = indexingDatabase.name.toLowerCase();
    if (db == 'webofscience' || db == 'wos' || db == 'scopus') {
      return _internationalJournalPoints;
    }
    
    return 0.0;
  }

  /// ✅ 5. المجموع النهائي للبحث
  double get finalPoints {
    return (adminScore + journalPoints) * participationPercentage;
  }

  /// ✅ هل البحث محتاج تقييم الأدمن؟
  bool get needsAdminReview => adminScore == 0.0;

  // =============================================================
  // ================ JSON Methods ===============================
  // =============================================================

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
      quartile: json['quartile'],
      isLocalJournal: json['isLocalJournal'] ?? false,
      localJournalCriteria: json['localJournalCriteria'] != null
          ? Map<String, bool>.from(json['localJournalCriteria'])
          : null,
      certifiedReportNumber: json['certifiedReportNumber'],
      certifiedReportFileUrl: json['certifiedReportFileUrl'],
      adminScore: (json['adminScore'] ?? 0).toDouble(),
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
      'quartile': quartile,
      'isLocalJournal': isLocalJournal,
      'localJournalCriteria': localJournalCriteria,
      'certifiedReportNumber': certifiedReportNumber,
      'certifiedReportFileUrl': certifiedReportFileUrl,
      'adminScore': adminScore,
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
    String? quartile,
    bool? isLocalJournal,
    Map<String, bool>? localJournalCriteria,
    String? certifiedReportNumber,
    String? certifiedReportFileUrl,
    double? adminScore,
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
      quartile: quartile ?? this.quartile,
      isLocalJournal: isLocalJournal ?? this.isLocalJournal,
      localJournalCriteria: localJournalCriteria ?? this.localJournalCriteria,
      certifiedReportNumber: certifiedReportNumber ?? this.certifiedReportNumber,
      certifiedReportFileUrl: certifiedReportFileUrl ?? this.certifiedReportFileUrl,
      adminScore: adminScore ?? this.adminScore,
      paperFileUrl: paperFileUrl ?? this.paperFileUrl,
      paperFileType: paperFileType ?? this.paperFileType,
      indexingProofUrl: indexingProofUrl ?? this.indexingProofUrl,
      indexingProofType: indexingProofType ?? this.indexingProofType,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}