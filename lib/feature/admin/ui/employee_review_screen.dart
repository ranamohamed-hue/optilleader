import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/routing/routes.dart'; 

class EmployeeReviewScreen extends StatelessWidget {
  const EmployeeReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'review.app_bar_title'.tr(),
          style: TextStyle(fontSize: 16.sp),
        ),
        leading: IconButton(
  icon: Icon(Icons.arrow_back_ios_new, size: 20.sp),
  onPressed: () {
    if (context.canPop()) {
      context.pop(); 
    } else {
      context.go(Routes.admin); 
    }
  },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.h),
          child: Container(color: colorScheme.secondary, height: 2.h),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 15.h),

            // 1. كارت بيانات الموظف الأساسية
            _buildEmployeeInfoCard(context),

            // 2. الموقف الوظيفي والترقيات
            _buildSection(
              context,
              title: 'review.sections.promotions'.tr(),
              isActive: true,
              child: _buildPromotionsTable(context),
            ),

            // 3. العبء التدريسي والمقررات
            _buildSection(
              context,
              title: 'review.sections.teaching_load'.tr(),
              isActive: true,
              child: _buildTeachingLoadTable(context),
              footerText: 'review.footers.load_reviewed'.tr(),
            ),

            // 4. المرفقات الإدارية
            _buildSection(
              context,
              title: 'review.sections.attachments'.tr(),
              isActive: false,
              child: _buildAttachmentsList(context),
              footerText: 'review.footers.docs_reviewed'.tr(),
            ),

            // 5. اختيار المحكم المختص
            _buildJudgeSelection(context),

            // 6. زر الاعتماد النهائي
            _buildSubmitButton(context),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'review.employee_name'.tr(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 18.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _infoRow('15/05/1975', 'review.birth_date'.tr()),
                  _infoRow('10/10/2000', 'review.join_date'.tr()),
                ],
              ),
            ),
            SizedBox(width: 15.w),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.secondary,
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 40.r,
                backgroundColor: theme.colorScheme.surface,
                child: Icon(
                  Icons.person,
                  size: 50.sp,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String value, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(color: Colors.grey, fontSize: 12.sp),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required bool isActive,
    required Widget child,
    String? footerText,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            trailing: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
                color: theme.colorScheme.primary,
              ),
            ),
            leading: Switch(
              value: isActive,
              onChanged: (v) {},
              activeColor: Colors.green,
            ),
          ),
          child,
          if (footerText != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(color: Colors.green.shade700),
              child: Text(
                footerText,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 11.sp),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPromotionsTable(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: Table(
        border: TableBorder.all(
          color: theme.colorScheme.secondary.withOpacity(0.2),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.05),
            ),
            children: [
              _TableCell('review.tables.new_title'.tr(), isHeader: true),
              _TableCell('review.tables.old_title'.tr(), isHeader: true),
              _TableCell('review.tables.date'.tr(), isHeader: true),
            ],
          ),
          const TableRow(
            children: [
              _TableCell('أستاذ مشارك'),
              _TableCell('أستاذ مساعد'),
              _TableCell('2020'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeachingLoadTable(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(10.w),
      child: Table(
        border: TableBorder.all(
          color: theme.colorScheme.secondary.withOpacity(0.2),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.05),
            ),
            children: [
              _TableCell('review.tables.hours_count'.tr(), isHeader: true),
              _TableCell('review.tables.course_name'.tr(), isHeader: true),
            ],
          ),
          const TableRow(
            children: [_TableCell('4'), _TableCell('خوارزميات (CS301)')],
          ),
          const TableRow(
            children: [_TableCell('4'), _TableCell('ذكاء اصطناعي (CS405)')],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsList(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(15.w, 0, 15.w, 15.h),
      child: Column(
        children: [
          _attachmentItem('شهادة التخرج الموثقة (PhD).pdf'),
          _attachmentItem('إثبات الدرجة الوظيفية الحالية.pdf'),
        ],
      ),
    );
  }

  Widget _attachmentItem(String name) {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              name,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12.sp),
            ),
          ),
          SizedBox(width: 10.w),
          Icon(
            Icons.picture_as_pdf,
            color: const Color(0xFFC62828),
            size: 22.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildJudgeSelection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15.w),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'review.fields.select_judge'.tr(),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
        items: const [
          DropdownMenuItem(value: '1', child: Text('د. سارة محمود')),
        ],
        onChanged: (v) {},
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15.w),
      child: SizedBox(
        width: double.infinity,
        height: 55.h,
        child: ElevatedButton.icon(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          icon: const Icon(Icons.verified_user),
          label: Text(
            'review.fields.submit_btn'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;
  const _TableCell(this.text, {this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(10.w),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? theme.colorScheme.primary : null,
        ),
      ),
    );
  }
}
