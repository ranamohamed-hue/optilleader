import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/routing/routes.dart';

class CareerInfoPage extends StatelessWidget {
  const CareerInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 90.h,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20.sp),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(Routes.user);
            }
          },
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.secondary, width: 1.5),
              ),
              child: CircleAvatar(
                radius: 22.r,
                backgroundColor: colorScheme.secondary.withOpacity(0.2),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'career.title'.tr(),
                  style: textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Dr. Mohamed Adel', // يمكن استبداله بمتغير من الـ Profile لاحقاً
                  style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
            const Spacer(),
            InkWell(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: colorScheme.secondary.withOpacity(0.5),
                  ),
                ),
                child: Icon(
                  Icons.edit_note_rounded,
                  color: colorScheme.secondary,
                  size: 22.sp,
                ),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.h),
          child: Container(color: colorScheme.secondary, height: 2.h),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildSectionHeader(
              context,
              Icons.school_outlined,
              'career.sections.credentials'.tr(),
            ),
            _buildCredentialCard(
              context,
              'career.degrees.phd'.tr(),
              'career.specs.computer_eng'.tr(),
              'Cairo University',
              '15/06/2015',
            ),
            _buildCredentialCard(
              context,
              'career.degrees.msc'.tr(),
              'career.specs.software_eng'.tr(),
              'Cairo University',
              '02/09/2010',
            ),
            _buildCredentialCard(
              context,
              'career.degrees.bsc'.tr(),
              'career.specs.computer_science'.tr(),
              'Cairo University',
              '10/07/2007',
              isLast: true,
            ),
            SizedBox(height: 25.h),
            _buildSectionHeader(
              context,
              Icons.history_edu_rounded,
              'career.sections.path'.tr(),
            ),
            _buildCareerPathCard(context),
            SizedBox(height: 25.h),
            _buildSectionHeader(
              context,
              Icons.badge_outlined,
              'career.sections.current_employment'.tr(),
            ),
            _buildCurrentInfoCard(context),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  // الـ Widgets الفرعية كما هي في الكود الخاص بكِ مع التأكد من ربط النصوص بـ .tr()
  Widget _buildSectionHeader(
    BuildContext context,
    IconData icon,
    String title,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 15.w),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
        border: Border.all(color: colorScheme.secondary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.secondary, size: 22.sp),
          SizedBox(width: 10.w),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialCard(
    BuildContext context,
    String degree,
    String spec,
    String inst,
    String date, {
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
        borderRadius: isLast
            ? BorderRadius.vertical(bottom: Radius.circular(15.r))
            : BorderRadius.zero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: colorScheme.secondary,
                size: 16.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                degree,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.only(left: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(spec, style: theme.textTheme.bodyMedium),
                Text(inst, style: theme.textTheme.bodySmall),
                Text(
                  date,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareerPathCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15.r)),
        border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'career.current_role'.tr(args: ['28/04/2018']),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 8.h),
          Text(
            'career.experience'.tr(args: ['6']),
            style: TextStyle(
              color: colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Divider(height: 30.h, color: colorScheme.primary.withOpacity(0.1)),
          Text(
            'career.previous_positions'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          SizedBox(height: 10.h),
          _buildHistoryItem(
            context,
            'career.roles.lecturer'.tr(),
            '2011 – 2015',
          ),
          _buildHistoryItem(context, 'career.roles.ta'.tr(), '2007 – 2011'),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, String title, String period) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(Icons.arrow_right, color: colorScheme.secondary),
          Text(
            '$title: ',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          Text(
            period,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15.r)),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            context,
            Icons.account_balance_rounded,
            'career.labels.dept'.tr(),
            'Faculty of Engineering',
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            context,
            Icons.assignment_ind_rounded,
            'career.labels.type'.tr(),
            'career.employment_type.permanent'.tr(),
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            context,
            Icons.calendar_today_rounded,
            'career.labels.hire_date'.tr(),
            '15/07/2007',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colorScheme.primary, size: 18.sp),
        SizedBox(width: 8.w),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        SizedBox(width: 5.w),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
