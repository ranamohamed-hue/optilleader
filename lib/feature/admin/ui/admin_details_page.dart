import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:optialeader/feature/admin/logic/admin_approval/admin_approval_cubit.dart';
import 'package:optialeader/feature/admin/logic/admin_approval/admin_approval_state.dart';
import 'package:optialeader/feature/doctor/data/model/activities_model.dart';
import 'package:optialeader/feature/doctor/data/model/research_paper_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';

class AdminDetailsPage extends StatefulWidget {
  final dynamic item;
  final String doctorUid;
  final String type;

  const AdminDetailsPage({
    super.key,
    required this.item,
    required this.doctorUid,
    required this.type,
  });

  @override
  State<AdminDetailsPage> createState() => _AdminDetailsPageState();
}

class _AdminDetailsPageState extends State<AdminDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryNavy = theme.primaryColor;
    final goldAccent = theme.colorScheme.secondary;

    return BlocListener<AdminApprovalCubit, AdminApprovalState>(
      listener: (context, state) {
        if (state is AdminApprovalLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('admin_request.success_msg'.tr()),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        } else if (state is AdminApprovalError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.type == 'paper'
                ? 'admin_request.title_paper'.tr()
                : 'admin_request.title_activity'.tr(),
          ),
          backgroundColor: primaryNavy,
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.r),
                child: widget.type == 'paper'
                    ? _buildPaperDetails(
                        context,
                        widget.item as ResearchPaperModel,
                      )
                    : _buildActivityDetails(
                        context,
                        widget.item as ActivityModel,
                      ),
              ),
            ),
            _buildActionButtons(context, primaryNavy, goldAccent),
          ],
        ),
      ),
    );
  }

  // ✅✅ تفاصيل البحث العلمي الكاملة
  Widget _buildPaperDetails(BuildContext context, ResearchPaperModel paper) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(
          title: 'admin_request.info_card.basic_info'.tr(),
          icon: Icons.description_outlined,
          children: [
            _buildDetailRow('admin_request.info_card.label_title_ar'.tr(), paper.titleAr),
            _buildDetailRow('admin_request.info_card.label_title_en'.tr(), paper.titleEn),
            _buildDetailRow('admin_request.info_card.label_year'.tr(), '${paper.publicationYear}'),
            _buildDetailRow('admin_request.info_card.label_journal'.tr(), paper.journalUrl, isLink: true),
          ],
        ),
        SizedBox(height: 15.h),
        _buildInfoCard(
          title: 'admin_request.journal_card.title'.tr(),
          icon: Icons.menu_book_rounded,
          children: [
            _buildDetailRow('admin_request.journal_card.label_name'.tr(), paper.journalName),
            _buildDetailRow('admin_request.journal_card.label_issn'.tr(), paper.issn),
            _buildDetailRow(
              'admin_request.journal_card.label_if'.tr(),
              paper.impactFactor.isEmpty ? 'admin_request.label_undefined'.tr() : paper.impactFactor,
            ),
            _buildDetailRow(
              'admin_request.journal_card.label_scope'.tr(),
              paper.journalScope.name,
            ),
            _buildDetailRow('admin_request.journal_card.label_level'.tr(), paper.journalLevel.name),
            _buildDetailRow('admin_request.journal_card.label_indexing'.tr(), paper.indexingDatabase.name),
            _buildDetailRow(
              'admin_request.journal_card.label_top_tier'.tr(),
              paper.isTopTierJournal ? 'common.yes'.tr() : 'common.no'.tr(),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        _buildInfoCard(
          title: 'admin_request.authors_card.title'.tr(),
          icon: Icons.people_alt_rounded,
          children: [
            _buildDetailRow('admin_request.authors_card.label_order'.tr(), '${paper.authorOrder}'),
            _buildDetailRow('admin_request.authors_card.label_total'.tr(), '${paper.totalAuthors}'),
            _buildDetailRow(
              'admin_request.authors_card.label_same_spec'.tr(),
              '${paper.authorsInSameSpecialty}',
            ),
          ],
        ),
        SizedBox(height: 15.h),
        _buildInfoCard(
          title: 'admin_request.files_section.title'.tr(),
          icon: Icons.attach_file_rounded,
          children: [
            _buildFileRow('admin_request.files_section.label_paper'.tr(), paper.paperFileUrl, paper.paperFileType),
            if (paper.indexingProofUrl != null &&
                paper.indexingProofUrl!.isNotEmpty)
              _buildFileRow(
                'admin_request.files_section.label_proof'.tr(),
                paper.indexingProofUrl!,
                paper.indexingProofType,
              ),
          ],
        ),
      ],
    );
  }

  // ✅✅ تفاصيل النشاط/الدورة الكاملة
  Widget _buildActivityDetails(BuildContext context, ActivityModel activity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(
          title: 'admin_request.activity_card.basic_info'.tr(),
          icon: Icons.event_note_rounded,
          children: [
            _buildDetailRow('admin_request.activity_card.label_title'.tr(), activity.title),
            _buildDetailRow('admin_request.activity_card.label_org'.tr(), activity.organization),
            _buildDetailRow('admin_request.activity_card.label_date'.tr(), activity.date),
            _buildDetailRow(
              'admin_request.activity_card.label_hours'.tr(),
              '${activity.durationHours ?? 'admin_request.label_undefined'.tr()}',
            ),
            _buildDetailRow('admin_request.activity_card.label_part_type'.tr(), activity.participationType),
            _buildDetailRow('admin_request.activity_card.label_type'.tr(), activity.type),
          ],
        ),
        SizedBox(height: 15.h),
        if (activity.type == 'course')
          _buildInfoCard(
            title: 'admin_request.course_card.title'.tr(),
            icon: Icons.school_rounded,
            children: [
              _buildDetailRow('admin_request.course_card.label_cat'.tr(), activity.courseCategory.name),
              _buildDetailRow('admin_request.course_card.label_scope'.tr(), activity.courseScope.name),
            ],
          ),
      ],
    );
  }

  // ✅✅ كارت المعلومات الموحد
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor, size: 22.sp),
              SizedBox(width: 10.w),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          Divider(height: 20.h),
          ...children,
        ],
      ),
    );
  }

  // ✅✅ صف البيانات (مفتاح: قيمة)
  Widget _buildDetailRow(String label, String value, {bool isLink = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140.w, // عرض ثابت للمفتاح
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'admin_request.label_undefined'.tr() : value,
              style: TextStyle(
                fontSize: 13.sp,
                color: isLink ? Colors.blue : Colors.black87,
                decoration: isLink
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // ✅✅ زر فتح الملف
  Widget _buildFileRow(String label, String url, String? fileType) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        fileType == 'pdf' ? Icons.picture_as_pdf : Icons.image,
        color: fileType == 'pdf' ? Colors.red : Colors.blue,
      ),
      title: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
      ),
      subtitle: Text(
        fileType?.toUpperCase() ?? 'FILE',
        style: TextStyle(fontSize: 11.sp, color: Colors.grey),
      ),
      trailing: Icon(Icons.open_in_new, color: Theme.of(context).primaryColor),
      onTap: () async {
        if (url.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('admin_request.file_row.url_error'.tr())));
          return;
        }
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('admin_request.file_row.open_fail'.tr())));
          }
        }
      },
    );
  }

  // ✅✅ أزرار الموافقة والرفض
  Widget _buildActionButtons(
    BuildContext context,
    Color primaryNavy,
    Color goldAccent,
  ) {
    return BlocBuilder<AdminApprovalCubit, AdminApprovalState>(
      builder: (context, state) {
        final isLoading = state is AdminApprovalLoading;
        return Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: isLoading
              ? Center(child: CircularProgressIndicator(color: goldAccent))
              : Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: () {
                          if (widget.type == 'paper') {
                            context.read<AdminApprovalCubit>().approveResearch(
                              widget.doctorUid,
                              widget.item.id,
                              widget.item.titleAr,
                            );
                          } else {
                            context.read<AdminApprovalCubit>().approveActivity(
                              widget.doctorUid,
                              widget.item.id,
                              widget.item.title,
                            );
                          }
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(
                          'admin_request.actions.approve'.tr(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                          side: BorderSide(
                            color: Colors.red.shade700,
                            width: 1.5,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: () async {
                          final reason = await _showRejectDialog(context);
                          if (reason != null && context.mounted) {
                            if (widget.type == 'paper') {
                              context.read<AdminApprovalCubit>().rejectResearch(
                                widget.doctorUid,
                                widget.item.id,
                                widget.item.titleAr,
                                reason,
                              );
                            } else {
                              context.read<AdminApprovalCubit>().rejectActivity(
                                widget.doctorUid,
                                widget.item.id,
                                widget.item.title,
                                reason,
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.cancel_outlined),
                        label: Text(
                          'admin_request.actions.reject'.tr(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Future<String?> _showRejectDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        title: Text('admin_request.reject_dialog.title'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('admin_request.reject_dialog.body'.tr()),
            const SizedBox(height: 15),
            TextField(
              controller: controller,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                hintText: 'admin_request.reject_dialog.hint'.tr(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('admin_request.reject_dialog.cancel'.tr()),
          ),
          TextButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: () => Navigator.pop(
              context,
              controller.text.isEmpty ? 'admin_pending.default_rejection'.tr() : controller.text.trim(),
            ),
            child: Text('admin_request.reject_dialog.confirm'.tr()),
          ),
        ],
      ),
    );
  }
}