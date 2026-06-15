import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/doctor/data/model/activities_model.dart';
import 'package:optialeader/feature/doctor/data/model/research_paper_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';
import 'package:optialeader/feature/admin/logic/admin_approval/admin_approval_cubit.dart';
import 'package:optialeader/feature/admin/logic/admin_approval/admin_approval_state.dart';
import 'package:go_router/go_router.dart';

class AdminPendingRequestsPage extends StatefulWidget {
  const AdminPendingRequestsPage({super.key});

  @override
  State<AdminPendingRequestsPage> createState() =>
      _AdminPendingRequestsPageState();
}

class _AdminPendingRequestsPageState extends State<AdminPendingRequestsPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminApprovalCubit>().getPendingRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('admin_pending.title'.tr())),
      body: BlocConsumer<AdminApprovalCubit, AdminApprovalState>(
        listener: (context, state) {
          if (state is AdminApprovalError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is AdminApprovalLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('admin_pending.success_msg'.tr()),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 1),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminApprovalLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminApprovalLoaded) {
            if (state.doctorsWithPending.isEmpty) {
              return Center(
                child: Text(
                  'admin_pending.no_pending'.tr(),
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () =>
                  context.read<AdminApprovalCubit>().getPendingRequests(),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.doctorsWithPending.length,
                itemBuilder: (context, index) {
                  final doctor = state.doctorsWithPending[index];
                  return _buildDoctorSection(context, doctor);
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildDoctorSection(BuildContext context, DoctorProfileModel doctor) {
    final pendingPapers = doctor.researchPapers
        .where((p) => p.status == VerificationStatus.pending)
        .toList();
    
    // ✅✅ التعديل هنا: بقينا بنفلتر من الـ activities بس (لأنها بقت ليستة موحدة)
    final pendingActivities = doctor.activities
        .where((a) => a.status == VerificationStatus.pending)
        .toList();

    return ExpansionTile(
      title: Text(
        doctor.nameAr,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${'admin_pending.papers_count'.tr(args: ['${pendingPapers.length}'])} - ${'admin_pending.activities_count'.tr(args: ['${pendingActivities.length}'])}',
      ),
      children: [
        if (pendingPapers.isNotEmpty)
          ...pendingPapers
              .map((paper) => _buildPaperCard(context, doctor.uid ?? '', paper))
              .toList(),
        if (pendingActivities.isNotEmpty)
          ...pendingActivities
              .map(
                (activity) =>
                    _buildActivityCard(context, doctor.uid ?? '', activity),
              )
              .toList(),
      ],
    );
  }

Widget _buildPaperCard(
    BuildContext context,
    String doctorUid,
    ResearchPaperModel paper,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: ListTile(
        onTap: () {
          context.push('/admin/pending-requests/details', extra: {
            'item': paper,
            'doctorUid': doctorUid,
            'type': 'paper',
          });
        },
        leading: const Icon(Icons.description_outlined, color: Colors.blue),
        title: Text(paper.titleAr, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${'admin_pending.journal'.tr()} ${paper.journalName}'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text('admin_pending.pending_review'.tr(), style: const TextStyle(color: Colors.orange, fontSize: 12)),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    String doctorUid,
    ActivityModel activity,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: ListTile(
        onTap: () {
          context.push('/admin/pending-requests/details', extra: {
            'item': activity,
            'doctorUid': doctorUid,
            'type': 'activity',
          });
        },
        leading: const Icon(Icons.event_note_rounded, color: Colors.teal),
        title: Text(activity.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${'admin_pending.organization'.tr()} ${activity.organization}'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text('admin_pending.pending_review'.tr(), style: const TextStyle(color: Colors.orange, fontSize: 12)),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        isThreeLine: true,
      ),
    );
  }

  Future<String?> _showRejectDialog(BuildContext context) async {
    final TextEditingController reasonController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('admin_pending.reject_dialog.title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('admin_pending.reject_dialog.body'.tr()),
            const SizedBox(height: 15),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                hintText: 'admin_pending.reject_dialog.hint'.tr(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              final reason = reasonController.text.trim().isEmpty
                  ? 'admin_pending.default_rejection'.tr()
                  : reasonController.text.trim();
              Navigator.pop(context, reason);
            },
            child: Text('admin_pending.reject_dialog.confirm'.tr(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}