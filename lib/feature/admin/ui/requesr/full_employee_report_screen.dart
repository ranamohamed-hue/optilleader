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
    final primaryNavy = theme.primaryColor;
    final goldAccent = theme.colorScheme.secondary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryNavy,
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
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildEmployeeHeader(context),
            SizedBox(height: 20.h),
            _buildInfoRow(
              context,
              "report.fields.hiring_date".tr(),
              "15/09/2014",
            ),
            SizedBox(height: 20.h),
            _buildActionSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: theme.primaryColor,
            child: Icon(Icons.person, color: theme.colorScheme.secondary),
          ),
          SizedBox(width: 15.w),
          Text(
            'د. رامي عبد العزيز',
            style: TextStyle(
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: "report.select_judge".tr()),
          items: [
            "judge.name1".tr(),
            "judge.name2".tr(),
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) {},
        ),
        SizedBox(height: 20.h),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            minimumSize: Size(double.infinity, 55.h),
          ),
          onPressed: () {},
          child: Text(
            "report.btn_approve".tr(),
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
        ),
        SizedBox(width: 10.w),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }
}
