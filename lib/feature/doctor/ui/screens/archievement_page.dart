import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_state.dart';

import 'package:optialeader/feature/doctor/data/model/activities_model.dart';
import 'package:optialeader/feature/doctor/data/model/research_paper_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';

class AchievementsLogPage extends StatelessWidget {
  final String doctorUid;

  const AchievementsLogPage({super.key, required this.doctorUid});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BlocBuilder<DoctorDataCubit, DoctorDataState>(
      builder: (context, state) {
        DoctorProfileModel? doctor;
        if (state is DoctorLoaded) {
          doctor = state.doctor;
        }

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
                  if (context.canPop()) { context.pop(); } else { context.go(Routes.user); }
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
                      backgroundImage: (doctor?.profileImage.isNotEmpty ?? false)
                          ? CachedNetworkImageProvider(doctor!.profileImage)
                          : null,
                      child: (doctor?.profileImage.isEmpty ?? true)
                          ? Icon(Icons.person, color: Colors.white, size: 20.sp)
                          : null,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text('achievements.title'.tr(), style: theme.appBarTheme.titleTextStyle),
                  const Spacer(),
                  Icon(Icons.emoji_events, color: colorScheme.secondary),
                ],
              ),
              bottom: TabBar(
                isScrollable: true,
                indicatorColor: colorScheme.secondary,
                indicatorWeight: 3,
                labelColor: colorScheme.secondary,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(text: "achievements.tabs.research".tr()), // ✅
                  Tab(text: "achievements.tabs.conferences".tr()), // ✅
                  Tab(text: "achievements.tabs.activities".tr()), // ✅
                  Tab(text: "achievements.tabs.courses".tr()), // ✅
                ],
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildResearchList(context, doctor?.researchPapers ?? []),
                      _buildActivitiesList(context, (doctor?.activities ?? []).where((a) => a.type == 'conference').toList()),
                      _buildActivitiesList(context, (doctor?.activities ?? []).where((a) => a.type != 'conference' && a.type != 'course').toList()),
                      // ✅ [تعديل] استخدام trainingCourses من الموديل
                      _buildActivitiesList(context, doctor?.trainingCourses ?? []),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        int currentIndex = DefaultTabController.of(context).index;
                        if (currentIndex == 0) {
                          // ✅ [تعديل] شيلت الـ / من أول اللينك عشان يشتغل كـ SubRoute
                          context.push('addResearch?uid=$doctorUid');
                        } else {
                          context.push('addActivity?uid=$doctorUid');
                        }
                      },
                      icon: Icon(Icons.add_circle_outline, color: colorScheme.primary),
                      label: Text(
                        'achievements.add_new'.tr(), // ✅
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.secondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResearchList(BuildContext context, List<ResearchPaperModel> papers) {
    if (papers.isEmpty) {
      return Center(child: Text("achievements.no_research".tr(), style: TextStyle(color: Colors.grey))); // ✅
    }
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: papers.length,
      itemBuilder: (context, index) {
        final paper = papers[index];
        return _buildItemCard(
          title: paper.titleAr,
          subtitle: paper.journalName,
          date: paper.publicationYear.toString(),
          status: paper.status,
        );
      },
    );
  }

  Widget _buildActivitiesList(BuildContext context, List<ActivityModel> activities) {
    if (activities.isEmpty) {
      return Center(child: Text("achievements.no_activities".tr(), style: TextStyle(color: Colors.grey))); // ✅
    }
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return _buildItemCard(
          title: activity.title,
          subtitle: activity.organization,
          date: activity.date,
          status: activity.status,
        );
      },
    );
  }

  Widget _buildItemCard({
    required String title,
    required String subtitle,
    required String date,
    required VerificationStatus status,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4.h),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusChip(status),
                SizedBox(height: 4.h),
                Text(date, style: TextStyle(color: Colors.grey, fontSize: 11.sp)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(VerificationStatus status) {
    Color color;
    IconData icon;
    String text;

    switch (status) {
      case VerificationStatus.approved:
        color = Colors.green;
        icon = Icons.check_circle;
        text = 'achievements.status.accepted'.tr(); // ✅
        break;
      case VerificationStatus.rejected:
        color = Colors.red;
        icon = Icons.cancel;
        text = 'achievements.status.rejected'.tr(); // ✅
        break;
      case VerificationStatus.pending:
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        text = 'achievements.status.under_review'.tr(); // ✅
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 4.w),
          Text(text, style: TextStyle(color: color, fontSize: 11.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}