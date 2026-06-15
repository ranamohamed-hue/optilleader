import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:optialeader/feature/admin/data/model/nomination_request_model.dart';
import 'package:optialeader/feature/admin/logic/nomination_request_logic/nomination_request_cubit.dart';
import 'package:optialeader/feature/admin/logic/nomination_request_logic/nomonation_request_state.dart';
import 'package:optialeader/feature/database_admin/data/models/judge_profile_model.dart';

class FullEmployeeReportScreen extends StatefulWidget {
  final NominationRequestModel request;
  const FullEmployeeReportScreen({super.key, required this.request});

  @override
  State<FullEmployeeReportScreen> createState() =>
      _FullEmployeeReportScreenState();
}

class _FullEmployeeReportScreenState extends State<FullEmployeeReportScreen> {
  String? _selectedJudgeId;
  List<JudgeProfileModel> _judgesList = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryNavy = theme.primaryColor;
    final goldAccent = theme.colorScheme.secondary;
    bool isEvaluated =
        widget.request.status == NominationRequestModel.statusEvaluated;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryNavy,
        elevation: 0,
        title: Text(
          'report.title'.tr(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sp),
          onPressed: () => context.pop(),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.h),
          child: Container(color: goldAccent, height: 2.h),
        ),
      ),
      body: BlocListener<NominationRequestCubit, NominationRequestState>(
        listener: (context, state) {
          if (state is NominationRequestActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message.tr()),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          } else if (state is NominationRequestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message.tr()),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              _buildEmployeeHeader(context, goldAccent, primaryNavy),
              SizedBox(height: 25.h),
              _buildSystemPointsCard(context, primaryNavy, goldAccent),
              SizedBox(height: 25.h),
              if (widget.request.declarationFileUrl != null)
                _buildDeclarationSection(context, primaryNavy),
              SizedBox(height: 25.h),
              if (isEvaluated)
                _buildEvaluatorReportAndFinalDecision(
                  context,
                  primaryNavy,
                  goldAccent,
                )
              else if (widget.request.status ==
                  NominationRequestModel.statusPendingAdmin)
                _buildActionSection(context, primaryNavy, goldAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeHeader(BuildContext context, Color gold, Color navy) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: navy.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: gold.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35.r,
            backgroundColor: navy,
            backgroundImage: widget.request.doctorImageUrl != null
                ? NetworkImage(widget.request.doctorImageUrl!)
                : null,
            child: widget.request.doctorImageUrl == null
                ? Icon(Icons.person, color: gold, size: 30.sp)
                : null,
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.request.doctorName,
                  style: TextStyle(
                    color: navy,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
                Text(
                  "${'report.header.role_label'.tr()} ${widget.request.targetRole.tr()}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
                ),
                if (widget.request.collegeName != null)
                  Text(
                    "${widget.request.collegeName} - ${widget.request.departmentName ?? ''}",
                    style: TextStyle(color: Colors.grey[500], fontSize: 11.sp),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemPointsCard(BuildContext context, Color navy, Color gold) {
    final List<dynamic> itemsDetails =
        (widget.request.systemPointsBreakdown['evaluated_items_details']
            is List)
        ? widget.request.systemPointsBreakdown['evaluated_items_details']
              as List<dynamic>
        : [];

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'report.system_points.title'.tr(),
            style: TextStyle(
              color: navy,
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
            ),
          ),
          Divider(height: 20.h),

          if (itemsDetails.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
              decoration: BoxDecoration(
                color: navy.withOpacity(0.05),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.r),
                  topRight: Radius.circular(8.r),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      "النشاط/البحث",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11.sp,
                        color: navy,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "النوع",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11.sp,
                        color: navy,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "التفاصيل",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11.sp,
                        color: navy,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "الدرجة",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11.sp,
                        color: navy,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            ...itemsDetails.map((detail) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        detail['title'] ?? '',
                        style: TextStyle(fontSize: 11.sp),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        detail['type'] ?? '',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "${detail['category']} - ${detail['scope']}",
                        style: TextStyle(fontSize: 9.sp),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "${(detail['points'] is double) ? (detail['points'] as double).toStringAsFixed(1) : detail['points']}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11.sp,
                          color: gold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            SizedBox(height: 15.h),
          ] else ...[
            ...widget.request.systemPointsBreakdown.entries
                .where((e) => e.key != 'evaluated_items_details')
                .map(
                  (entry) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          "${entry.value} ${'report.system_points.point_unit'.tr()}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                            color: navy,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],

          Divider(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'report.system_points.total'.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                  color: navy,
                ),
              ),
              Text(
                "${widget.request.systemTotalPoints} ${'report.system_points.point_unit'.tr()}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                  color: gold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeclarationSection(BuildContext context, Color navy) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: TextButton.icon(
        onPressed: () async {
          final url = Uri.parse(widget.request.declarationFileUrl!);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('report.declaration.open_link_msg'.tr())),
            );
          }
        },
        icon: Icon(
          Icons.picture_as_pdf,
          color: Colors.blue.shade700,
          size: 24.sp,
        ),
        label: Text(
          'report.declaration.view_file'.tr(),
          style: TextStyle(
            color: Colors.blue.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildActionSection(BuildContext context, Color navy, Color gold) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'report.actions.transfer_title'.tr(),
            style: TextStyle(
              color: navy,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 12.h),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'judge')
                .where('is_active', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return Center(
                  child: Text(
                    'خطأ في تحميل المحكمين (تأكد من إنشاء الـ Index)',
                    style: TextStyle(color: Colors.red, fontSize: 12.sp),
                    textAlign: TextAlign.center,
                  ),
                );
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                return Center(
                  child: Text(
                    'لا يوجد محكمين نشطين حالياً',
                    style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                  ),
                );

              _judgesList = snapshot.data!.docs
                  .map(
                    (doc) => JudgeProfileModel.fromJson(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    ),
                  )
                  .toList();
              return DropdownButtonFormField<String>(
                value: _selectedJudgeId,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: gold),
                  ),
                ),
                hint: Text(
                  'report.actions.choose_judge'.tr(),
                  style: TextStyle(fontSize: 14.sp),
                ),
                items: _judgesList
                    .map(
                      (judge) => DropdownMenuItem<String>(
                        value: judge.uid,
                        child: Text(
                          judge.nameAr,
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (id) => setState(() => _selectedJudgeId = id),
              );
            },
          ),
          SizedBox(height: 30.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showRejectionDialog(
                    context,
                    NominationRequestModel.statusRejectedByAdmin,
                  ),
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  label: Text(
                    'report.actions.reject'.tr(),
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_selectedJudgeId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('report.actions.judge_required'.tr()),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    String evaluatorName = 'غير معروف';
                    for (var judge in _judgesList) {
                      if (judge.uid == _selectedJudgeId) {
                        evaluatorName = judge.nameAr;
                        break;
                      }
                    }
                    context.read<NominationRequestCubit>().adminTakeAction(
                      request: widget.request,
                      newStatus: NominationRequestModel.statusPendingEvaluator,
                      evaluatorId: _selectedJudgeId!,
                      evaluatorName: evaluatorName,
                    );
                  },
                  icon: Icon(Icons.swap_horiz, color: navy, size: 20.sp),
                  label: Text(
                    'report.actions.transfer'.tr(),
                    style: TextStyle(
                      color: navy,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluatorReportAndFinalDecision(
    BuildContext context,
    Color navy,
    Color gold,
  ) {
    final request = widget.request;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.rate_review_rounded,
                color: Colors.orange.shade800,
                size: 22.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                "تقرير التقييم النفسي والسلوكي",
                style: TextStyle(
                  color: Colors.orange.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
          Divider(height: 20.h, color: Colors.orange.shade200),
          _buildReportRow(
            context,
            Icons.person_outline,
            "اسم المحكم:",
            request.evaluatorName ?? 'غير محدد',
          ),
          SizedBox(height: 12.h),
          _buildReportRow(
            context,
            Icons.calendar_month,
            "موعد المقابلة:",
            request.interviewDate != null
                ? "${request.interviewDate!.day}/${request.interviewDate!.month}/${request.interviewDate!.year}"
                : 'لم يحدد',
          ),
          SizedBox(height: 12.h),
          _buildReportRow(
            context,
            Icons.score_rounded,
            "درجة التقييم:",
            "${request.evaluatorPoints ?? 0} نقطة",
          ),
          SizedBox(height: 12.h),
          Text(
            "ملاحظات المحكم:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: navy,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 5.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.orange.shade100),
            ),
            child: Text(
              request.evaluatorNotes ?? 'لا توجد ملاحظات',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[800]),
            ),
          ),
          SizedBox(height: 30.h),
          Text(
            "القرار النهائي:",
            style: TextStyle(
              color: navy,
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
            ),
          ),
          SizedBox(height: 15.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showRejectionDialog(
                    context,
                    NominationRequestModel.statusFinalRejected,
                  ),
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  label: Text(
                    'رفض نهائي',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      context.read<NominationRequestCubit>().adminTakeAction(
                        request: widget.request,
                        newStatus: NominationRequestModel
                            .statusFinalApprovedPendingAnnouncement,
                      ),
                  icon: const Icon(Icons.verified_rounded, color: Colors.white),
                  label: Text(
                    'موافقة نهائية',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: Colors.orange.shade800),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
            color: Colors.grey[700],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13.sp,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  void _showRejectionDialog(BuildContext context, String rejectionStatus) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "سبب الرفض",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(hintText: "اكتب السبب هنا..."),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('report.reject_dialog.cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<NominationRequestCubit>().adminTakeAction(
                request: widget.request,
                newStatus: rejectionStatus,
                rejectionReason: reasonController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'report.reject_dialog.confirm'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
