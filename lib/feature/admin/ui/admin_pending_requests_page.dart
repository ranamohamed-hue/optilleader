import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart'; // ✅ إضافة مكتبة الترجمة
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
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
      // ✅ ربط عنوان الـ Appbar
      appBar: AppBar(title: Text('admin_pending.title'.tr())),
      body: BlocConsumer<AdminApprovalCubit, AdminApprovalState>(
        listener: (context, state) {
          if (state is AdminApprovalError) {
            ScaffoldMessenger.of(context).showSnackBar(
              // ✅ إضافة .tr() لرسالة الخطأ
              SnackBar(content: Text(state.message.tr())),
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
                  // ✅ ربط نص عدم وجود طلبات
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
    final pendingConferences = doctor.conferences
        .where((c) => c.status == VerificationStatus.pending)
        .toList();
    final pendingExhibitions = doctor.exhibitions
        .where((e) => e.status == VerificationStatus.pending)
        .toList();
    final pendingCourses = doctor.courses
        .where((c) => c.status == VerificationStatus.pending)
        .toList();

    int totalPending =
        pendingPapers.length +
        pendingConferences.length +
        pendingExhibitions.length +
        pendingCourses.length;

    if (totalPending == 0) return SizedBox.shrink();

    return ExpansionTile(
      title: Text(
        doctor.nameAr,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      // ✅ ربط نص عدد الطلبات باستخدام args
      subtitle: Text('admin_pending.review_count'.tr(args: [totalPending.toString()])),
      children: [
        ...pendingPapers.map(
          (paper) => _buildItemCard(
            context,
            doctor.uid ?? '',
            paper,
            'paper',
            paper.titleAr,
            Icons.description,
            Colors.blue,
          ),
        ),
        ...pendingConferences.map(
          (conf) => _buildItemCard(
            context,
            doctor.uid ?? '',
            conf,
            'conference',
            conf.title,
            Icons.groups,
            Colors.orange,
          ),
        ),
        ...pendingExhibitions.map(
          (exh) => _buildItemCard(
            context,
            doctor.uid ?? '',
            exh,
            'exhibition',
            exh.title,
            Icons.brush,
            Colors.deepOrange,
          ),
        ),
        ...pendingCourses.map(
          (course) => _buildItemCard(
            context,
            doctor.uid ?? '',
            course,
            'course',
            course.title,
            Icons.school,
            Colors.teal,
          ),
        ),
      ],
    );
  }

  // ✅ كارت موحد لكل الأنشطة
  Widget _buildItemCard(
    BuildContext context,
    String doctorUid,
    dynamic item,
    String type,
    String title,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: ListTile(
        onTap: () {
          context.push(
            '/admin/pending-requests/details',
            extra: {'item': item, 'doctorUid': doctorUid, 'type': type},
          );
        },
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            // ✅ ربط حالة "قيد المراجعة"
            child: Text(
              'admin_pending.pending_review'.tr(),
              style: const TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        isThreeLine: true,
      ),
    );
  }
}