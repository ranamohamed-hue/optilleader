import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';

enum ExhibitionVenue {
  internationalAbroad,
  internationalEgypt,
  accreditedHalls,
  publicHalls,
}

class ArtExhibitionModel {
  final String id;
  final String title;
  final ExhibitionVenue venue; 
  final int numberOfWorks;
  final bool isInternationalType;
  
  final String proofFileUrl; 
  final String proofFileType; 
  final String? researcherNotes; 

  final VerificationStatus status;
  final String? rejectionReason;

  ArtExhibitionModel({
    required this.id,
    required this.title,
    required this.venue,
    required this.numberOfWorks,
    this.isInternationalType = false,
    required this.proofFileUrl,
    required this.proofFileType,
    this.researcherNotes,
    this.status = VerificationStatus.pending,
    this.rejectionReason,
  });

  /// ✅ هل نطبق الشرط الاستثنائي؟
  bool get isExceptionalCase =>
      isInternationalType && numberOfWorks >= 2;

  /// ✅ حساب النقاط الأساسية
  double get basePoints {
    if (isExceptionalCase) return 0.0;
    
    switch (venue) {
      case ExhibitionVenue.internationalAbroad:
        return numberOfWorks >= 5 ? 8.0 : 0.0;
      case ExhibitionVenue.internationalEgypt:
        return 7.0;
      case ExhibitionVenue.accreditedHalls:
        return 6.5;
      case ExhibitionVenue.publicHalls:
        return 5.0;
    }
  }

  factory ArtExhibitionModel.fromJson(Map<String, dynamic> json) {
    return ArtExhibitionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      venue: ExhibitionVenue.values.firstWhere(
        (e) => e.name == json['venue'],
        orElse: () => ExhibitionVenue.publicHalls,
      ),
      numberOfWorks: json['numberOfWorks'] ?? 1,
      isInternationalType: json['isInternationalType'] ?? false,
      proofFileUrl: json['proofFileUrl'] ?? '',
      proofFileType: json['proofFileType'] ?? 'image',
      researcherNotes: json['researcherNotes'],
      status: parseVerificationStatus(json['status']),
      rejectionReason: json['rejectionReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'venue': venue.name,
      'numberOfWorks': numberOfWorks,
      'isInternationalType': isInternationalType,
      'proofFileUrl': proofFileUrl,
      'proofFileType': proofFileType,
      'researcherNotes': researcherNotes,
      'status': status.name,
      'rejectionReason': rejectionReason,
    };
  }

  ArtExhibitionModel copyWith({
    String? id,
    String? title,
    ExhibitionVenue? venue,
    int? numberOfWorks,
    bool? isInternationalType,
    String? proofFileUrl,
    String? proofFileType,
    String? researcherNotes,
    VerificationStatus? status,
    String? rejectionReason,
  }) {
    return ArtExhibitionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      venue: venue ?? this.venue,
      numberOfWorks: numberOfWorks ?? this.numberOfWorks,
      isInternationalType: isInternationalType ?? this.isInternationalType,
      proofFileUrl: proofFileUrl ?? this.proofFileUrl,
      proofFileType: proofFileType ?? this.proofFileType,
      researcherNotes: researcherNotes ?? this.researcherNotes,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}