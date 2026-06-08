enum VerificationStatus {
  pending,   // قيد المراجعة
  approved,  // معتمد
  rejected,  // مرفوض
}

//  نطاق المجلة
enum JournalScope {
  specialized,      // متخصصة
  nonSpecialized,   // غير متخصصة (عامة)
}

//  مستوى المجلة
enum JournalLevel {
  international, // عالمية/دولية
  local,         // محلية/إقليمية
}

enum IndexingDatabase {
  scopus,       // سكوبس
  webOfScience, // ويب أوف ساينس
  local,        // قواعد بيانات محلية
  other,        // أخرى
}

// دالة مساعدة لتحويل النص من الفايرستور إلى Enum
T enumFromString<T>(Iterable<T> values, String? value) {
  return values.firstWhere(
    (type) => type.toString().split('.').last == value,
    orElse: () => values.first,
  );
}

// دالة لحالة الاعتماد
VerificationStatus parseVerificationStatus(String? status) {
  switch (status) {
    case 'approved': return VerificationStatus.approved;
    case 'rejected': return VerificationStatus.rejected;
    default: return VerificationStatus.pending;
  }
}