import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/routing/routes.dart';

class DoctorProfileDataPage extends StatelessWidget {
  const DoctorProfileDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header (SliverAppBar)
          SliverAppBar(
            expandedHeight: 160.0.h,
            pinned: true,
            backgroundColor: colorScheme.primary, // Navy
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
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.secondary,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 35.r,
                          backgroundColor: Colors.white10,
                          child: Icon(
                            Icons.person,
                            color: colorScheme.secondary,
                            size: 40.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Dr. Sara Mohamed", // يمكن تمريرها لاحقاً كـ Variable
                            style: textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "add_doctor.personal_section".tr(),
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              // 1. General Information Card
              _buildSectionCard(
                context,
                icon: Icons.badge_outlined,
                title: "add_doctor.personal_section".tr(),
                children: [
                  _buildField(
                    context,
                    "add_doctor.name_ar".tr(),
                    "add_doctor.name_ar".tr(),
                  ),
                  _buildField(
                    context,
                    "add_doctor.phone".tr(),
                    "+20 123 456 789",
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          context,
                          "add_doctor.social_status".tr(),
                          "...",
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _buildField(
                          context,
                          "statuses.active".tr(),
                          "Active",
                        ),
                      ),
                    ],
                  ),
                  _buildField(
                    context,
                    "add_doctor.birth_date".tr(),
                    "DD/MM/YYYY",
                  ),
                ],
              ),

              // 2. Academic & Career History
              _buildSectionCard(
                context,
                icon: Icons.school_outlined,
                title: "add_doctor.academic_section".tr(),
                children: [
                  _buildField(
                    context,
                    "add_doctor.job_ar".tr(),
                    "Enter job...",
                  ),
                ],
              ),

              _buildSectionCard(
                context,
                icon: Icons.contact_mail_outlined,
                title: "add_doctor.contact_section".tr(),
                children: [
                  _buildField(
                    context,
                    "add_doctor.email".tr(),
                    "sara@university.edu.eg",
                  ),
                  _buildField(
                    context,
                    "add_doctor.address_ar".tr(),
                    "City, District, St.",
                  ),
                ],
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 30.h),
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text("add_doctor.save_btn".tr()),
                ),
              ),
              SizedBox(height: 50.h),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      elevation: theme.cardTheme.elevation,
      shape: theme.cardTheme.shape,
      color: theme.cardTheme.color,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.secondary, size: 22.sp),
                SizedBox(width: 10.w),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Divider(height: 30.h, color: colorScheme.primary.withOpacity(0.1)),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildField(BuildContext context, String label, String hint) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          TextFormField(decoration: InputDecoration(hintText: hint)),
        ],
      ),
    );
  }
}
