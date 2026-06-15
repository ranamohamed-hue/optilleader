class InterviewScoringModel {
  DateTime interviewDate;
  double personalScore;     // القسم الأول: 15 درجة
  double scientificScore;   // القسم الثاني: 40 درجة
  double communicationScore;// القسم الثالث: 25 درجة
  double leadershipScore;   // القسم الرابع: 20 درجة
  String notes;
  bool isDraft; 

  InterviewScoringModel({
    required this.interviewDate,
    this.personalScore = 0,
    this.scientificScore = 0,
    this.communicationScore = 0,
    this.leadershipScore = 0,
    this.notes = '',
    this.isDraft = false,
  });

  // حساب المجموع الكلي
  double get totalScore => 
      personalScore + scientificScore + communicationScore + leadershipScore;

  // التحقق من صحة الدرجات (مش بتتجاوز الحد الأقصى)
  bool get isValid {
    if (personalScore > 15 || personalScore < 0) return false;
    if (scientificScore > 40 || scientificScore < 0) return false;
    if (communicationScore > 25 || communicationScore < 0) return false;
    if (leadershipScore > 20 || leadershipScore < 0) return false;
    return true;
  }

  Map<String, dynamic> toMap() {
    return {
      'interviewDate': interviewDate.toIso8601String(),
      'personalScore': personalScore,
      'scientificScore': scientificScore,
      'communicationScore': communicationScore,
      'leadershipScore': leadershipScore,
      'notes': notes,
      'isDraft': isDraft,
      'totalScore': totalScore,
    };
  }
  factory InterviewScoringModel.fromMap(Map<String, dynamic> map) {
    return InterviewScoringModel(
      // ✅ التعديل: بنشوف لو التاريخ موجود قبل ما نحوله، ولو مش موجود نحط تاريخ حالي عشان مبيوقعش
      interviewDate: (map['interviewDate'] != null && map['interviewDate'].toString().isNotEmpty)
          ? DateTime.parse(map['interviewDate'])
          : DateTime.now(), 
          
      personalScore: (map['personalScore'] ?? 0).toDouble(),
      scientificScore: (map['scientificScore'] ?? 0).toDouble(),
      communicationScore: (map['communicationScore'] ?? 0).toDouble(),
      leadershipScore: (map['leadershipScore'] ?? 0).toDouble(),
      notes: map['notes'] ?? '',
      isDraft: map['isDraft'] ?? false,
    );
  }
}