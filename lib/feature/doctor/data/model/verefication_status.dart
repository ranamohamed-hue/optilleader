enum VerificationStatus {
  pending,   // قيد المراجعة
  approved,  // معتمد
  rejected,  // مرفوض
}

// ✅ نطاق المجلة
enum JournalScope {
  specialized,      // متخصصة
  nonSpecialized,   // غير متخصصة (عامة)
}

// ✅ مستوى المجلة
enum JournalLevel {
  international, // عالمية/دولية
  local,         // محلية/إقليمية
}
// ✅ قاعدة البيانات المفهرسة فيها
enum IndexingDatabase {
  scopus,       // سكوبس
  webOfScience, // ويب أوف ساينس
  local,        // قواعد بيانات محلية (مثل الإسكندرية)
  other,        // أخرى
}
// ✅ دالة مساعدة لتحويل النص من الفايرستور إلى Enum بأمان
T enumFromString<T>(Iterable<T> values, String? value) {
  return values.firstWhere(
    (type) => type.toString().split('.').last == value,
    orElse: () => values.first, // لو الاسم مش موجود، ارجع لأول قيمة (الافتراضية)
  );
}

// دالة خاصة بحالة الاعتماد عشان نضمن التعامل مع null
VerificationStatus parseVerificationStatus(String? status) {
  switch (status) {
    case 'approved': return VerificationStatus.approved;
    case 'rejected': return VerificationStatus.rejected;
    default: return VerificationStatus.pending;
  }
}
