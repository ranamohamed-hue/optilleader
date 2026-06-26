import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/feature/doctor/data/model/research_paper_model.dart';
import 'package:optialeader/feature/doctor/logic/research_paper/research_paper_cubit.dart';
import 'package:optialeader/feature/doctor/logic/research_paper/research_paper_state.dart';

/// ============================================================
/// صفحة تفاصيل البحث العلمي المعلق (خاصة للأدمن)
/// وظيفتها:
/// 1. عرض بيانات البحث والمجلة بطاقة أنيقة.
/// 2. السماح للأدمن بفتح ملف التقرير الموثق (إن وجد).
/// 3. إتاحة خانة لإدخال "درجة الأدمن" (الـ 90 درجة) قبل الموافقة.
/// ============================================================
class PendingRequestDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> extra;

  const PendingRequestDetailsScreen({super.key, required this.extra});

  @override
  State<PendingRequestDetailsScreen> createState() =>
      _PendingRequestDetailsScreenState();
}

class _PendingRequestDetailsScreenState
    extends State<PendingRequestDetailsScreen> {
  late final dynamic item;
  late final String doctorUid;
  late final String type;

  // كنترولر لإدخال درجة الأدمن (اللي هتتضاف للنقاط الآلية في الموديل)
  final _scoreController = TextEditingController(text: '0.0');
  final _rejectionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    item = widget.extra['item'];
    doctorUid = widget.extra['doctorUid'];
    type = widget.extra['type'];

    // لو البحث كان عنده بالفعل درجة أدمن سابقة، نعرضها في الخانة
    if (item is ResearchPaperModel) {
      _scoreController.text = (item as ResearchPaperModel).adminScore
          .toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _rejectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // الصفحة دي مصممة خصيصاً لعرض تفاصيل الأبحاث فقط
    if (type == 'paper' && item is ResearchPaperModel) {
      final paper = item as ResearchPaperModel;
      return _buildPaperDetails(context, theme, paper);
    }

    // لو تم استدعاء نوع تاني بالخطأ، نعرض شاشة افتراضية
    return Scaffold(
      appBar: AppBar(title: Text('pending_details.generic_title'.tr())),
      body: Center(child: Text('pending_details.generic_body'.tr())),
    );
  }

  /// بناء واجهة تفاصيل البحث
  Widget _buildPaperDetails(
    BuildContext context,
    ThemeData theme,
    ResearchPaperModel paper,
  ) {
    // التحقق من وجود ملف التقرير الموثق لعرض قسم إدخال درجة الأدمن
    final hasReport =
        paper.certifiedReportFileUrl != null &&
        paper.certifiedReportFileUrl!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text('pending_details.appbar_title'.tr()),
        centerTitle: true,
      ),
      body: BlocListener<ResearchCubit, ResearchState>(
        listener: (context, state) {
          setState(() => _isLoading = state is ResearchLoading);

          if (state is ResearchSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('pending_details.success_msg'.tr()),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          } else if (state is ResearchError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
            setState(() => _isLoading = false);
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. كارت بيانات البحث الأساسية والمجلة
              _buildInfoCard(theme, paper),
              SizedBox(height: 20.h),

              // 2. قسم التقرير الموثق ودرجة الأدمن (يظهر فقط لو الملف موجود)
              if (hasReport) ...[
                _buildCommitteeReportSection(theme, paper),
                SizedBox(height: 30.h),
              ] else ...[
                Text(
                  'pending_details.no_report_note'.tr(),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 30.h),
              ],

              // 3. أزرار الموافقة والرفض
              _buildActionButtons(paper),
            ],
          ),
        ),
      ),
    );
  }

  /// كارت عرض بيانات البحث والمجلة (بدون تفاصيل النقاط والترتيب عشان الصفحة دي مخصصة للأبحاث)
  Widget _buildInfoCard(ThemeData theme, ResearchPaperModel paper) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            paper.titleAr,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          Divider(height: 24.h),
          _buildDetailRow(
            'pending_details.journal_name'.tr(),
            paper.journalName,
          ),
          _buildDetailRow(
            'pending_details.database'.tr(),
            paper.indexingDatabase.name.toUpperCase(),
          ),
          if (paper.quartile != null)
            _buildDetailRow(
              'pending_details.quartile'.tr(),
              paper.quartile!.toUpperCase(),
            ),
          _buildDetailRow(
            'pending_details.year'.tr(),
            paper.publicationYear.toString(),
          ),
          _buildDetailRow(
            'pending_details.rank'.tr(),
            '${paper.authorOrder} / ${paper.totalAuthors}',
          ),
        ],
      ),
    );
  }

  /// قسم مخصص لفتح التقرير الموثق وإدخال درجة الأدمن
  Widget _buildCommitteeReportSection(
    ThemeData theme,
    ResearchPaperModel paper,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user, color: theme.primaryColor, size: 24.sp),
              SizedBox(width: 10.w),
              Text(
                'pending_details.report_title'.tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // زر لفتح ملف الـ PDF
          InkWell(
            onTap: () async {
              final uri = Uri.parse(paper.certifiedReportFileUrl!);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.picture_as_pdf, color: Colors.red, size: 28.sp),
                  SizedBox(width: 12.w),
                  Text(
                    'pending_details.open_report'.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.open_in_new, color: theme.primaryColor),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // خانة إدخال درجة الأدمن (اللي هتضاف على نقاط الـ Quartile)
          Text(
            'pending_details.score_label'.tr(),
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _scoreController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'pending_details.score_hint'.tr(),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              prefixIcon: Icon(Icons.star, color: Colors.amber),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'pending_details.score_note'.tr(),
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// أزرار الموافقة (مع إرسال درجة الأدمن) والرفض
  Widget _buildActionButtons(ResearchPaperModel paper) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton.icon(
            onPressed: _isLoading
                ? null
                : () {
                    final score = double.tryParse(_scoreController.text) ?? 0.0;
                    context.read<ResearchCubit>().approveResearch(
                      doctorUid,
                      paper.id,
                      adminScore: score,
                    );
                  },
            icon: _isLoading
                ? SizedBox(
                    width: 20.h,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(Icons.check_circle_outline),
            label: Text(
              'pending_details.approve_btn'.tr(),
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : () => _showRejectDialog(paper),
            icon: Icon(Icons.cancel_outlined, color: Colors.red),
            label: Text(
              'pending_details.reject_btn'.tr(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.red, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// ديلوج popup كتابة سبب الرفض
  void _showRejectDialog(ResearchPaperModel paper) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('pending_details.reject_dialog_title'.tr()),
        content: TextField(
          controller: _rejectionController,
          decoration: InputDecoration(
            hintText: 'pending_details.reject_hint'.tr(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('pending_details.cancel'.tr()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<ResearchCubit>().rejectResearch(
                doctorUid,
                paper.id,
                _rejectionController.text.trim(),
              );
              Navigator.pop(ctx);
            },
            child: Text(
              'pending_details.confirm_reject'.tr(),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// صف لعرض سطر من البيانات
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
