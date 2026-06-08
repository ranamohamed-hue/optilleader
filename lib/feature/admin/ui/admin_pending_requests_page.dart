import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ [إضافة] عشان AdminApprovalRepoImpl
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/admin/data/repo/admin_approval/admin_aproval_repo_impl.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/doctor/data/model/activities_model.dart';
import 'package:optialeader/feature/doctor/data/model/research_paper_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';
import 'package:optialeader/feature/admin/logic/admin_approval/admin_approval_cubit.dart';
import 'package:optialeader/feature/admin/logic/admin_approval/admin_approval_state.dart';
import 'package:optialeader/feature/doctor/data/repo/activities/activity_repo.dart';
import 'package:optialeader/feature/doctor/data/repo/research_paper/research_paper_repo.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';

class AdminPendingRequestsPage extends StatelessWidget {
  const AdminPendingRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminApprovalCubit( // ✅ [تعديل] اسم الكلاس بال Case الصح
        adminApprovalRepo: AdminApprovalRepoImpl( // ✅ [تعديل] بنبعت الريبو Implementation
          firebaseFirestore: FirebaseFirestore.instance,
          researchPaperRepo: context.read<ResearchPaperRepo>(),
          activityRepo: context.read<ActivityRepo>(),
          notificationRepo: context.read<NotificationRepo>(),
        ),
      )..getPendingRequests(),
      child: Scaffold(
        appBar: AppBar(title: const Text('طلبات الاعتماد المعلقة')),
        body: BlocConsumer<AdminApprovalCubit, AdminApprovalState>( // ✅ [تعديل] اسم الكلاس بال Case الصح
          listener: (context, state) {
            if (state is AdminApprovalError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is AdminApprovalLoading) return const Center(child: CircularProgressIndicator());
            if (state is AdminApprovalLoaded) {
              if (state.doctorsWithPending.isEmpty) {
                return const Center(child: Text('لا توجد طلبات معلقة حالياً'));
              }
              return ListView.builder(
                itemCount: state.doctorsWithPending.length,
                itemBuilder: (context, index) {
                  final doctor = state.doctorsWithPending[index];
                  return _buildDoctorSection(context, doctor);
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildDoctorSection(BuildContext context, DoctorProfileModel doctor) {
    final pendingPapers = doctor.researchPapers.where((p) => p.status == VerificationStatus.pending).toList();
    final pendingActivities = [...doctor.activities, ...doctor.trainingCourses].where((a) => a.status == VerificationStatus.pending).toList();

    return ExpansionTile(
      title: Text(doctor.nameAr, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${pendingPapers.length} أبحاث - ${pendingActivities.length} أنشطة'),
      children: [
        if (pendingPapers.isNotEmpty)
          ...pendingPapers.map((paper) => _buildPaperCard(context, doctor.uid ?? '', paper)).toList(),
        if (pendingActivities.isNotEmpty)
          ...pendingActivities.map((activity) => _buildActivityCard(context, doctor.uid ?? '', activity)).toList(),
      ],
    );
  }

  Widget _buildPaperCard(BuildContext context, String doctorUid, ResearchPaperModel paper) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('بحث: ${paper.titleAr}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('المجلة: ${paper.journalName}'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text('اعتماد'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () => context.read<AdminApprovalCubit>().approveResearch(doctorUid, paper.id, paper.titleAr),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.close, color: Colors.white),
                  label: const Text('رفض'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => _showRejectDialog(context, () {
                    context.read<AdminApprovalCubit>().rejectResearch(doctorUid, paper.id, paper.titleAr, 'لم يستوفي الشروط');
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, String doctorUid, ActivityModel activity) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('نشاط: ${activity.title}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('الجهة: ${activity.organization}'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text('اعتماد'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () => context.read<AdminApprovalCubit>().approveActivity(doctorUid, activity.id, activity.title),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.close, color: Colors.white),
                  label: const Text('رفض'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => _showRejectDialog(context, () {
                    context.read<AdminApprovalCubit>().rejectActivity(doctorUid, activity.id, activity.title, 'لم يستوفي الشروط');
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, VoidCallback onReject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الرفض'),
        content: const Text('هل أنت متأكد من رفض هذا الطلب؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              onReject();
              Navigator.pop(context);
            },
            child: const Text('رفض', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}