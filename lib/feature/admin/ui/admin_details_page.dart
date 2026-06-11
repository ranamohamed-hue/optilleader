import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:optialeader/feature/admin/logic/admin_approval/admin_approval_cubit.dart';
import 'package:optialeader/feature/admin/logic/admin_approval/admin_approval_state.dart';

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
    return BlocListener<AdminApprovalCubit, AdminApprovalState>(
      listener: (context, state) {
        if (state is AdminApprovalLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم الإجراء بنجاح'), backgroundColor: Colors.green),
          );
          context.pop();
        } else if (state is AdminApprovalError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('تفاصيل الطلب')),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  _buildInfoCard(),
                  SizedBox(height: 20.h),
                  _buildFileSection(context),
                ],
              ),
            ),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('البيانات الأساسية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp)),
            const Divider(),
            // نستخدم العنوان بناءً على ما إذا كان بحث أو نشاط
            _buildDetailRow('العنوان:', widget.type == 'paper' ? widget.item.titleAr : widget.item.title),
            _buildDetailRow('الحالة:', 'معلق'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
          Text(value, style: TextStyle(fontSize: 14.sp)),
        ],
      ),
    );
  }

 Widget _buildFileSection(BuildContext context) {
  return Card(
    child: ListTile(
      leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
      title: const Text('عرض الملف المرفق'),
      trailing: const Icon(Icons.open_in_new),
      onTap: () async {
        // 1. استخراج الرابط من الـ item
        final String rawUrl = widget.item.paperFileUrl ?? '';
        
        if (rawUrl.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرابط غير موجود')));
          return;
        }

        // 2. تنظيف وتشفير الرابط (مهم جداً للروابط التي تحتوي رموزاً)
        final String encodedUrl = Uri.encodeFull(rawUrl);
        final Uri url = Uri.parse(encodedUrl);

        // 3. المحاولة بـ externalApplication
        try {
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            // محاولة أخيرة في حالة فشل التحقق
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        } catch (e) {
          debugPrint('Error launching URL: $e');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تعذر فتح الملف، تأكد من وجود متصفح')),
            );
          }
        }
      },
    ),
  );
}

  Widget _buildActionButtons(BuildContext context) {
    return BlocBuilder<AdminApprovalCubit, AdminApprovalState>(
      builder: (context, state) {
        final isLoading = state is AdminApprovalLoading;
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)]),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        onPressed: () {
                          if (widget.type == 'paper') {
                            context.read<AdminApprovalCubit>().approveResearch(widget.doctorUid, widget.item.id, widget.item.titleAr);
                          } else {
                            context.read<AdminApprovalCubit>().approveActivity(widget.doctorUid, widget.item.id, widget.item.title);
                          }
                        },
                        child: const Text('اعتماد'),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                        onPressed: () async {
                          final reason = await _showRejectDialog(context);
                          if (reason != null && context.mounted) {
                            if (widget.type == 'paper') {
                              context.read<AdminApprovalCubit>().rejectResearch(widget.doctorUid, widget.item.id, widget.item.titleAr, reason);
                            } else {
                              context.read<AdminApprovalCubit>().rejectActivity(widget.doctorUid, widget.item.id, widget.item.title, reason);
                            }
                          }
                        },
                        child: const Text('رفض'),
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
      builder: (context) => AlertDialog(
        title: const Text('سبب الرفض'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'اكتب سبب الرفض هنا...'),
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('إلغاء')),
          TextButton(onPressed: () => context.pop(controller.text), child: const Text('تأكيد الرفض')),
        ],
      ),
    );
  }
}