import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/routing/routes.dart';

class FullEmployeeReportScreen extends StatelessWidget {
  const FullEmployeeReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryNavy = theme.primaryColor; // الكحلي
    final goldAccent = theme.colorScheme.secondary; // الذهبي

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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(Routes.admin);
            }
          },
        ),
        // خط ذهبي أسفل الـ AppBar لتعزيز المظهر الملكي
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.h),
          child: Container(color: goldAccent, height: 2.h),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            _buildEmployeeHeader(context, goldAccent, primaryNavy),
            SizedBox(height: 25.h),

            // قسم المعلومات الأساسية
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: theme.cardColor,
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
                children: [
                  _buildInfoRow(
                    context,
                    "report.fields.hiring_date".tr(),
                    "15/09/2014",
                    primaryNavy,
                    goldAccent,
                  ),
                ],
              ),
            ),

            SizedBox(height: 25.h),
            _buildActionSection(context, primaryNavy, goldAccent),
          ],
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
            child: Icon(Icons.person, color: gold, size: 30.sp),
          ),
          SizedBox(width: 15.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'د. رامي عبد العزيز',
                style: TextStyle(
                  color: navy,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
              Text(
                "Employee ID: #10293",
                style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
              ),
            ],
          ),
        ],
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
            "report.select_judge".tr(),
            style: TextStyle(
              color: navy,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 12.h),
          DropdownButtonFormField<String>(
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
            items: ["judge.name1".tr(), "judge.name2".tr()]
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, style: TextStyle(fontSize: 14.sp)),
                  ),
                )
                .toList(),
            onChanged: (v) {},
          ),
          SizedBox(height: 30.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: navy,
              foregroundColor: gold, // النص باللون الذهبي للفخامة
              minimumSize: Size(double.infinity, 55.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              elevation: 5,
            ),
            onPressed: () {
              // منطق الاعتماد هنا
            },
            child: Text(
              "report.btn_approve".tr(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    Color navy,
    Color gold,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 16.sp, color: gold),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: navy,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }
}
