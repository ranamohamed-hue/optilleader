import 'package:cloud_firestore/cloud_firestore.dart';

class NominationRequestModel {
  String? id;
  final String doctorId;
  final String doctorName;
  final String? doctorImageUrl;
  final String announcementId;
  final String targetRole;

  // College & Department Info
  final String? collegeId;
  final String? collegeName;
  final String? departmentId;
  final String? departmentName;

  // Automated Points
  final double systemTotalPoints;
  final Map<String, dynamic> systemPointsBreakdown;

  // Files
  final String? declarationFileUrl;

  // Evaluator Data (Old Simple Fields - Optional or used for summary)
  final String? evaluatorId;
  final String? evaluatorName;
  final DateTime? interviewDate;
  final double? evaluatorPoints; // Simple total if needed
  final String? evaluatorNotes;

  // ✅ Interview Evaluation (New Detailed Model)
  final Map<String, dynamic>? interviewEvaluation;

  // Status & Rejection
  String status;
  String? rejectionReason;
  String? adminNotes;

  // Timestamps
  final DateTime createdAt;
  DateTime? updatedAt;

  // Constants
  static const String statusPendingAdmin = 'pending_admin';
  static const String statusRejectedByAdmin = 'rejected_by_admin';
  static const String statusPendingEvaluator = 'pending_evaluator';
  static const String statusEvaluated = 'evaluated';
  static const String statusFinalApproved = 'final_approved';
  static const String statusFinalRejected = 'final_rejected';
  static const String statusFinalApprovedPendingAnnouncement =
      'final_approved_pending_announcement';

  NominationRequestModel({
    this.id,
    required this.doctorId,
    required this.doctorName,
    this.doctorImageUrl,
    required this.announcementId,
    required this.targetRole,
    this.collegeId,
    this.collegeName,
    this.departmentId,
    this.departmentName,
    required this.systemTotalPoints,
    required this.systemPointsBreakdown,
    this.declarationFileUrl,
    this.evaluatorId,
    this.evaluatorName,
    this.interviewDate,
    this.evaluatorPoints,
    this.evaluatorNotes,
    this.interviewEvaluation, // ✅ Added
    required this.status,
    this.rejectionReason,
    this.adminNotes,
    required this.createdAt,
    this.updatedAt,
  });

  factory NominationRequestModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return NominationRequestModel(
      id: documentId,
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      doctorImageUrl: map['doctorImageUrl'],
      announcementId: map['announcementId'] ?? '',
      targetRole: map['targetRole'] ?? '',
      collegeId: map['collegeId'],
      collegeName: map['collegeName'],
      departmentId: map['departmentId'],
      departmentName: map['departmentName'],
      systemTotalPoints: (map['systemTotalPoints'] ?? 0).toDouble(),
      systemPointsBreakdown: Map<String, dynamic>.from(
        map['systemPointsBreakdown'] ?? {},
      ),
      declarationFileUrl: map['declarationFileUrl'],
      evaluatorId: map['evaluatorId'],
      evaluatorName: map['evaluatorName'],
      interviewDate: map['interviewDate'] != null
          ? (map['interviewDate'] as Timestamp).toDate()
          : null,
      evaluatorPoints: map['evaluatorPoints'] != null
          ? (map['evaluatorPoints'] as num).toDouble()
          : null,
      evaluatorNotes: map['evaluatorNotes'],
      // ✅ Added fromMap logic
      interviewEvaluation: map['interviewEvaluation'] != null
          ? Map<String, dynamic>.from(map['interviewEvaluation'])
          : null,
      status: map['status'] ?? statusPendingAdmin,
      rejectionReason: map['rejectionReason'],
      adminNotes: map['adminNotes'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorImageUrl': doctorImageUrl,
      'announcementId': announcementId,
      'targetRole': targetRole,
      'collegeId': collegeId,
      'collegeName': collegeName,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'systemTotalPoints': systemTotalPoints,
      'systemPointsBreakdown': systemPointsBreakdown,
      'declarationFileUrl': declarationFileUrl,
      'evaluatorId': evaluatorId,
      'evaluatorName': evaluatorName,
      'interviewDate': interviewDate != null
          ? Timestamp.fromDate(interviewDate!)
          : null,
      'evaluatorPoints': evaluatorPoints,
      'evaluatorNotes': evaluatorNotes,
      // ✅ Added toMap logic
      'interviewEvaluation': interviewEvaluation,
      'status': status,
      'rejectionReason': rejectionReason,
      'adminNotes': adminNotes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  NominationRequestModel copyWith({
    String? id,
    String? doctorId,
    String? doctorName,
    String? doctorImageUrl,
    String? announcementId,
    String? targetRole,
    String? collegeId,
    String? collegeName,
    String? departmentId,
    String? departmentName,
    double? systemTotalPoints,
    Map<String, dynamic>? systemPointsBreakdown,
    String? declarationFileUrl,
    String? evaluatorId,
    String? evaluatorName,
    DateTime? interviewDate,
    double? evaluatorPoints,
    String? evaluatorNotes,
    Map<String, dynamic>? interviewEvaluation, // ✅ Added parameter
    String? status,
    String? rejectionReason,
    String? adminNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NominationRequestModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorImageUrl: doctorImageUrl ?? this.doctorImageUrl,
      announcementId: announcementId ?? this.announcementId,
      targetRole: targetRole ?? this.targetRole,
      collegeId: collegeId ?? this.collegeId,
      collegeName: collegeName ?? this.collegeName,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      systemTotalPoints: systemTotalPoints ?? this.systemTotalPoints,
      systemPointsBreakdown:
          systemPointsBreakdown ?? this.systemPointsBreakdown,
      declarationFileUrl: declarationFileUrl ?? this.declarationFileUrl,
      evaluatorId: evaluatorId ?? this.evaluatorId,
      evaluatorName: evaluatorName ?? this.evaluatorName,
      interviewDate: interviewDate ?? this.interviewDate,
      evaluatorPoints: evaluatorPoints ?? this.evaluatorPoints,
      evaluatorNotes: evaluatorNotes ?? this.evaluatorNotes,
      // ✅ Added assignment
      interviewEvaluation: interviewEvaluation ?? this.interviewEvaluation,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}