import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/feature/doctor/data/model/conferance_model.dart';
import 'package:optialeader/feature/doctor/data/model/courses_model.dart';
import 'package:optialeader/feature/doctor/data/model/exhibition_venue_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:optialeader/feature/admin/logic/admin_approval/admin_approval_cubit.dart';
import 'package:optialeader/feature/admin/logic/admin_approval/admin_approval_state.dart';
import 'package:optialeader/feature/doctor/data/model/research_paper_model.dart';

class AdminDetailsPage extends StatefulWidget {
  final dynamic item;
  final String doctorUid;
  final String type; // 'paper', 'conference', 'course', 'exhibition'

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
          title: Text(_getTitle()),
          backgroundColor: primaryNavy,
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.r),
                child: _buildDetailsContent(),
              ),
            ),
            _buildActionButtons(context, primaryNavy, goldAccent),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    switch (widget.type) {
      case 'paper': return 'admin_details.paper_title'.tr();
      case 'conference': return 'admin_details.conference_title'.tr();
      case 'course': return 'admin_details.course_title'.tr();
      case 'exhibition': return 'admin_details.exhibition_title'.tr();
      default: return 'admin_details.default_title'.tr();
    }
  }

  Widget _buildDetailsContent() {
    switch (widget.type) {
      case 'paper':
        return _buildPaperDetails(widget.item as ResearchPaperModel);
      case 'conference':
        return _buildConferenceDetails(widget.item as ConferenceModel);
      case 'course':
        return _buildCourseDetails(widget.item as CourseModel);
      case 'exhibition':
        return _buildExhibitionDetails(widget.item as ArtExhibitionModel);
      default:
        return Center(child: Text('admin_details.unknown_type'.tr()));
    }
  }

  // ====== تفاصيل البحث العلمي ======
  Widget _buildPaperDetails(ResearchPaperModel paper) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(
          title: 'admin_details.basic_data'.tr(),
          icon: Icons.description_outlined,
          children: [
            _buildDetailRow('admin_details.title_ar'.tr(), paper.titleAr),
            _buildDetailRow('admin_details.title_en'.tr(), paper.titleEn),
            _buildDetailRow('admin_details.pub_year'.tr(), '${paper.publicationYear}'),
            _buildDetailRow('admin_details.journal_url'.tr(), paper.journalUrl, isLink: true),
          ],
        ),
        SizedBox(height: 15.h),
        _buildInfoCard(
          title: 'admin_details.journal_data'.tr(),
          icon: Icons.menu_book_rounded,
          children: [
            _buildDetailRow('admin_details.journal_name'.tr(), paper.journalName),
            _buildDetailRow('ISSN', paper.issn),
            _buildDetailRow(
              'admin_details.impact_factor'.tr(),
              paper.impactFactor.isEmpty ? 'admin_details.not_specified'.tr() : paper.impactFactor,
            ),
            _buildDetailRow(
              'admin_details.journal_type'.tr(),
              paper.isLocalJournal ? 'admin_details.local'.tr() : 'admin_details.international'.tr(),
            ),
            if (!paper.isLocalJournal)
              _buildDetailRow(
                'admin_details.quartile'.tr(),
                paper.quartile?.toUpperCase() ?? 'admin_details.not_specified'.tr(),
              ),
            _buildDetailRow(
              'admin_details.top_tier'.tr(),
              paper.isTopTierJournal ? 'common.yes'.tr() : 'common.no'.tr(),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        _buildInfoCard(
          title: 'admin_details.researchers_data'.tr(),
          icon: Icons.people_alt_rounded,
          children: [
            _buildDetailRow('admin_details.author_order'.tr(), '${paper.authorOrder}'),
            _buildDetailRow('admin_details.total_authors'.tr(), '${paper.totalAuthors}'),
            _buildDetailRow('admin_details.same_specialty_authors'.tr(), '${paper.authorsInSameSpecialty}'),
          ],
        ),
        SizedBox(height: 15.h),
        _buildInfoCard(
          title: 'admin_details.report_attachments'.tr(),
          icon: Icons.attach_file_rounded,
          children: [
            if (paper.certifiedReportNumber != null)
              _buildDetailRow('admin_details.report_number'.tr(), paper.certifiedReportNumber!),
            if (paper.certifiedReportFileUrl != null)
              _buildFileRow('admin_details.report_file'.tr(), paper.certifiedReportFileUrl!, 'pdf'),
            _buildFileRow('admin_details.paper_file'.tr(), paper.paperFileUrl, paper.paperFileType),
            if (paper.indexingProofUrl != null)
              _buildFileRow('admin_details.indexing_proof'.tr(), paper.indexingProofUrl!, paper.indexingProofType),
          ],
        ),
      ],
    );
  }

  // ====== تفاصيل المؤتمر ======
  Widget _buildConferenceDetails(ConferenceModel conf) {
    return _buildInfoCard(
      title: 'admin_details.conference_data'.tr(),
      icon: Icons.groups_rounded,
      children: [
        _buildDetailRow('admin_details.title'.tr(), conf.title),
        _buildDetailRow(
          'admin_details.scope'.tr(),
          conf.isInternational ? 'admin_details.international'.tr() : 'admin_details.local'.tr(),
        ),
        _buildDetailRow(
          'admin_details.specialization'.tr(),
          conf.isSpecialized ? 'admin_details.specialized'.tr() : 'admin_details.non_specialized'.tr(),
        ),
        _buildDetailRow(
          'admin_details.published_proceedings'.tr(),
          conf.isPublished ? 'common.yes'.tr() : 'common.no'.tr(),
        ),
        _buildDetailRow('admin_details.participation_type'.tr(), _getParticipationTypeAr(conf.participationType)),
        SizedBox(height: 10.h),
        _buildFileRow('admin_details.certificate'.tr(), conf.certificateUrl, 'image'),
        if (conf.proceedingsUrl != null)
          _buildFileRow('admin_details.published_paper'.tr(), conf.proceedingsUrl!, 'pdf'),
      ],
    );
  }

  // ====== تفاصيل الدورة ======
  Widget _buildCourseDetails(CourseModel course) {
    return _buildInfoCard(
      title: 'admin_details.course_data'.tr(),
      icon: Icons.school_rounded,
      children: [
        _buildDetailRow('admin_details.course_name'.tr(), course.title),
        _buildDetailRow('admin_details.organization'.tr(), course.organization),
        _buildDetailRow('admin_details.date'.tr(), course.date),
        _buildDetailRow(
          'admin_details.hours'.tr(),
          '${course.durationHours ?? 'admin_details.not_specified'.tr()}',
        ),
        _buildDetailRow(
          'admin_details.course_type'.tr(),
          course.isMandatory ? 'admin_details.mandatory_leadership'.tr() : 'admin_details.evaluative'.tr(),
        ),
        if (!course.isMandatory) ...[
          _buildDetailRow('admin_details.category'.tr(), _getCourseCategoryAr(course.courseCategory)),
          _buildDetailRow('admin_details.scope'.tr(), _getCourseScopeAr(course.courseScope)),
        ],
        SizedBox(height: 10.h),
        _buildFileRow('admin_details.completion_certificate'.tr(), course.certificateUrl, course.certificateFileType),
      ],
    );
  }

  // ====== تفاصيل المعرض ======
  Widget _buildExhibitionDetails(ArtExhibitionModel exh) {
    return _buildInfoCard(
      title: 'admin_details.exhibition_data'.tr(),
      icon: Icons.brush_rounded,
      children: [
        _buildDetailRow('admin_details.title'.tr(), exh.title),
        _buildDetailRow('admin_details.works_count'.tr(), '${exh.numberOfWorks}'),
        _buildDetailRow(
          'admin_details.participation_type'.tr(),
          exh.isInternationalType ? 'admin_details.international_biennial'.tr() : 'admin_details.regular'.tr(),
        ),
        _buildDetailRow('admin_details.venue'.tr(), _getVenueAr(exh.venue)),
        if (exh.researcherNotes != null)
          _buildDetailRow('admin_details.researcher_notes'.tr(), exh.researcherNotes!),
        SizedBox(height: 10.h),
        _buildFileRow('admin_details.proof_file'.tr(), exh.proofFileUrl, exh.proofFileType),
      ],
    );
  }

  // ====== كارت المعلومات الموحد ======
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

  // ====== صف البيانات ======
  Widget _buildDetailRow(String label, String value, {bool isLink = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140.w,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'admin_details.not_specified'.tr() : value,
              style: TextStyle(
                fontSize: 13.sp,
                color: isLink ? Colors.blue : Colors.black87,
                decoration: isLink ? TextDecoration.underline : TextDecoration.none,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // ====== زر فتح الملف ======
  Widget _buildFileRow(String label, String? url, String? fileType) {
    if (url == null || url.isEmpty) return SizedBox.shrink();
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        fileType == 'pdf' ? Icons.picture_as_pdf : Icons.image,
        color: fileType == 'pdf' ? Colors.red : Colors.blue,
      ),
      title: Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
      subtitle: Text(
        fileType?.toUpperCase() ?? 'FILE',
        style: TextStyle(fontSize: 11.sp, color: Colors.grey),
      ),
      trailing: Icon(Icons.open_in_new, color: Theme.of(context).primaryColor),
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
    );
  }

  // ====== أزرار الموافقة والرفض ======
  Widget _buildActionButtons(BuildContext context, Color primaryNavy, Color goldAccent) {
    return BlocBuilder<AdminApprovalCubit, AdminApprovalState>(
      builder: (context, state) {
        final isLoading = state is AdminApprovalLoading;
        return Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, -2)),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        onPressed: () => _approveItem(),
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text('common.approve'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                          side: BorderSide(color: Colors.red.shade700, width: 1.5),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        onPressed: () async {
                          final reason = await _showRejectDialog(context);
                          if (reason != null) {
                            _rejectItem(reason);
                          }
                        },
                        icon: const Icon(Icons.cancel_outlined),
                        label: Text('common.reject'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  void _approveItem() {
    final cubit = context.read<AdminApprovalCubit>();
    switch (widget.type) {
      case 'paper':
        final item = widget.item as ResearchPaperModel;
        cubit.approveResearch(widget.doctorUid, item.id, item.titleAr);
        break;
      case 'conference':
        final item = widget.item as ConferenceModel;
        cubit.approveConference(widget.doctorUid, item.id, item.title);
        break;
      case 'course':
        final item = widget.item as CourseModel;
        cubit.approveCourse(widget.doctorUid, item.id, item.title);
        break;
      case 'exhibition':
        final item = widget.item as ArtExhibitionModel;
        cubit.approveExhibition(widget.doctorUid, item.id, item.title);
        break;
    }
  }

  void _rejectItem(String reason) {
    final cubit = context.read<AdminApprovalCubit>();
    switch (widget.type) {
      case 'paper':
        final item = widget.item as ResearchPaperModel;
        cubit.rejectResearch(widget.doctorUid, item.id, item.titleAr, reason);
        break;
      case 'conference':
        final item = widget.item as ConferenceModel;
        cubit.rejectConference(widget.doctorUid, item.id, item.title, reason);
        break;
      case 'course':
        final item = widget.item as CourseModel;
        cubit.rejectCourse(widget.doctorUid, item.id, item.title, reason);
        break;
      case 'exhibition':
        final item = widget.item as ArtExhibitionModel;
        cubit.rejectExhibition(widget.doctorUid, item.id, item.title, reason);
        break;
    }
  }

  // ====== دوال مساعدة ======
  String _getParticipationTypeAr(ParticipationType type) {
    switch (type) {
      case ParticipationType.paperPresentation: return 'admin_details.full_paper'.tr();
      case ParticipationType.abstractPresentation: return 'admin_details.abstract_paper'.tr();
      case ParticipationType.attendanceOnly: return 'admin_details.attendance_only'.tr();
    }
  }

  String _getCourseCategoryAr(CourseCategory category) {
    switch (category) {
      case CourseCategory.administrative: return 'admin_details.cat_administrative'.tr();
      case CourseCategory.specialized: return 'admin_details.cat_specialized'.tr();
      case CourseCategory.general: return 'admin_details.cat_general'.tr();
      default: return 'admin_details.not_specified'.tr();
    }
  }

  String _getCourseScopeAr(CourseScope scope) {
    switch (scope) {
      case CourseScope.international: return 'admin_details.international'.tr();
      case CourseScope.local: return 'admin_details.local'.tr();
      default: return 'admin_details.not_specified'.tr();
    }
  }

  String _getVenueAr(ExhibitionVenue venue) {
    switch (venue) {
      case ExhibitionVenue.internationalAbroad: return 'admin_details.venue_intl_abroad'.tr();
      case ExhibitionVenue.internationalEgypt: return 'admin_details.venue_intl_egypt'.tr();
      case ExhibitionVenue.accreditedHalls: return 'admin_details.venue_accredited'.tr();
      case ExhibitionVenue.publicHalls: return 'admin_details.venue_public'.tr();
    }
  }

  Future<String?> _showRejectDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        title: Text('admin_details.reject_reason_title'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('admin_details.reject_reason_body'.tr()),
            const SizedBox(height: 15),
            TextField(
              controller: controller,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                hintText: 'admin_details.reject_hint'.tr(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('common.cancel'.tr()),
          ),
          // ✅ تم تصحيح الـ Bug: استبدال TextButton بـ ElevatedButton
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(
              dialogContext,
              controller.text.trim().isEmpty ? 'admin_details.no_reason'.tr() : controller.text.trim(),
            ),
            child: Text('admin_details.confirm_reject'.tr()),
          ),
        ],
      ),
    );
  }
}