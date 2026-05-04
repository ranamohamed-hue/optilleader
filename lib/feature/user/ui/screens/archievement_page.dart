import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/routing/routes.dart';

class AchievementsLogPage extends StatelessWidget {
  const AchievementsLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          toolbarHeight: 80.h,
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
                  radius: 20.r,
                  backgroundColor: colorScheme.secondary.withOpacity(0.2),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              Text(
                'achievements.title'.tr(),
                style: theme.appBarTheme.titleTextStyle,
              ),

              const Spacer(),

              Icon(Icons.emoji_events, color: colorScheme.secondary),

              SizedBox(width: 10.w),

              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: colorScheme.secondary,
            indicatorWeight: 3,
            labelColor: colorScheme.secondary,
            unselectedLabelColor: Colors.white70,
            labelStyle: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            tabs: [
              Tab(text: "achievements.tabs.research".tr()),
              Tab(text: "achievements.tabs.conferences".tr()),
              Tab(text: "achievements.tabs.activities".tr()),
              Tab(text: "achievements.tabs.courses".tr()),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAchievementsList(context),
            Center(child: Text("achievements.tabs.conferences".tr())),
            Center(child: Text("achievements.tabs.activities".tr())),
            Center(child: Text("achievements.tabs.courses".tr())),
          ],
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add, size: 30),
        ),
      ),
    );
  }

  Widget _buildAchievementsList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.all(20.w),
      children: [
        _buildAchievementCard(
          context,
          title: "Machine Learning for Network Security",
          date: "15 March 2024",
          status: "achievements.status.accepted".tr(),
          statusColor: Colors.green.shade700,
          icon: Icons.check_circle_outline,
        ),
        _buildAchievementCard(
          context,
          title: "Blockchain Applications in IoT",
          date: "10 Dec 2023",
          status: "achievements.status.under_review".tr(),
          statusColor: Colors.orange.shade800,
          icon: Icons.hourglass_empty_rounded,
        ),
        _buildAchievementCard(
          context,
          title: "Cloud Computing in Higher Education",
          date: "02 Aug 2023",
          status: "achievements.status.rejected".tr(),
          statusColor: Colors.red.shade700,
          icon: Icons.cancel_outlined,
        ),

        SizedBox(height: 25.h),

        // قسم المقترحات البحثية
        Row(
          children: [
            Icon(Icons.analytics_outlined, color: colorScheme.primary),
            SizedBox(width: 8.w),
            Text(
              "achievements.sections.proposals".tr(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h),

        _buildSimpleCard(
          context,
          "Advanced Methodology in Crisis Management...",
        ),
        _buildSimpleCard(
          context,
          "Scientific Standards in Software Ranking...",
        ),
      ],
    );
  }

  Widget _buildAchievementCard(
    BuildContext context, {
    required String title,
    required String date,
    required String status,
    required Color statusColor,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      // استخدام ثيم الكارد الموحد
      margin: EdgeInsets.only(bottom: 15.h),
      elevation: theme.cardTheme.elevation,
      shape: theme.cardTheme.shape,
      color: theme.cardTheme.color,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                    SizedBox(width: 5.w),
                    Text(date, style: theme.textTheme.bodySmall),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: statusColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, size: 14, color: statusColor),
                      SizedBox(width: 5.w),
                      Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleCard(BuildContext context, String text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.w),
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: colorScheme.secondary, size: 18),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13.sp,
                color: colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
