import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart'; // ✅ [إضافة]

import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_state.dart';

class AchievementsLogPage extends StatelessWidget {
  const AchievementsLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // ✅ [تعديل] لفينا الصفحة بـ BlocBuilder عشان نصول لبيانات الدكتور
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
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(Routes.user);
                  }
                },
              ),
              title: Row(
                children: [
                  // ✅ [تعديل] عرض الصورة من السوبابيز
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.secondary,
                        width: 1.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 20.r,
                      backgroundColor: colorScheme.secondary.withOpacity(0.2),
                      backgroundImage:
                          (doctor?.profileImage.isNotEmpty ?? false)
                          ? CachedNetworkImageProvider(doctor!.profileImage)
                          : null,
                      child: (doctor?.profileImage.isEmpty ?? true)
                          ? Icon(Icons.person, color: Colors.white, size: 20.sp)
                          : null,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'achievements.title'.tr(),
                    style: theme.appBarTheme.titleTextStyle,
                  ),
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
                // ✅ [تعديل] التاب الأول (الأبحاث) بيجيب الداتا من الموديل
                _buildResearchList(context, doctor?.researchPapers ?? []),

                // التاب التاني (المؤتمرات) - حالياً مفيش List مخصصة في الموديل، ممكن نربطه بالأنشطة أو نسيه فاضي
                Center(child: Text("achievements.tabs.conferences".tr())),

                // ✅ [تعديل] التاب التالت (الأنشطة)
                _buildActivitiesList(context, doctor?.activities ?? []),

                // ✅ [تعديل] التاب الرابع (الكورسات)
                _buildCoursesList(context, doctor?.trainingCourses ?? []),
              ],
            ),
            // لو الصفحة للعرض فقط ممكن تشيلي الـ FAB ده، أو تربطيه بشاشة إضافة إنجاز
            // ✅ [تعديل] ربط الزرار بالصفحة اللي عملناها وبعت الـ uid
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (doctor?.uid != null) {
                  // بنستخدم context.push عشان يفتح الصفحة فوق الصفحة الحالية ونقدر نرجع بسهولة
                  context.push('uploadFiles?uid=${doctor!.uid}');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("حدث خطأ، لا يوجد معرف للمستخدم")),
                  );
                }
              },
              backgroundColor: colorScheme.secondary,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Icon(Icons.add, size: 28.sp, color: colorScheme.primary),
            ),
          ),
        );
      },
    );
  }

  // ✅ [إضافة] بناء لستة الأبحاث ديناميكياً
  Widget _buildResearchList(
    BuildContext context,
    List<dynamic> researchPapers,
  ) {
    if (researchPapers.isEmpty) {
      return Center(child: Text("No Research Papers Found"));
    }
    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      physics: const BouncingScrollPhysics(),
      itemCount: researchPapers.length,
      itemBuilder: (context, index) {
        final paper = researchPapers[index];
        // ⚠️ تأكد إن الموديل بتاعك فيه المتغيرات دي (title, date, status) لو اسمها مختلف عدله هنا
        return _buildAchievementCard(
          context,
          title: paper.title ?? "Untitled",
          date: paper.date ?? "-",
          status: paper.status ?? "achievements.status.under_review".tr(),
          statusColor: _getStatusColor(paper.status),
          icon: _getStatusIcon(paper.status),
        );
      },
    );
  }

  Widget _buildActivitiesList(BuildContext context, List<dynamic> activities) {
    if (activities.isEmpty) {
      return Center(child: Text("No Activities Found"));
    }
    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return _buildAchievementCard(
          context,
          title: activity.title ?? "Untitled",
          date: activity.date ?? "-",
          status: activity.status ?? "-",
          statusColor: _getStatusColor(activity.status),
          icon: _getStatusIcon(activity.status),
        );
      },
    );
  }

  Widget _buildCoursesList(BuildContext context, List<dynamic> courses) {
    if (courses.isEmpty) {
      return Center(child: Text("No Courses Found"));
    }
    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return _buildAchievementCard(
          context,
          title: course.title ?? "Untitled",
          date: course.date ?? "-",
          status: course.status ?? "-",
          statusColor: _getStatusColor(course.status),
          icon: _getStatusIcon(course.status),
        );
      },
    );
  }

  // ✅ [إضافة] دوال مساعدة لتحديد لون وأيقونة الحالة
  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    if (status.toLowerCase().contains('accept') || status == 'مقبول')
      return Colors.green.shade700;
    if (status.toLowerCase().contains('reject') || status == 'مرفوض')
      return Colors.red.shade700;
    if (status.toLowerCase().contains('review') || status == 'تحت المراجعة')
      return Colors.orange.shade800;
    return Colors.grey;
  }

  IconData _getStatusIcon(String? status) {
    if (status == null) return Icons.info_outline;
    if (status.toLowerCase().contains('accept') || status == 'مقبول')
      return Icons.check_circle_outline;
    if (status.toLowerCase().contains('reject') || status == 'مرفوض')
      return Icons.cancel_outlined;
    if (status.toLowerCase().contains('review') || status == 'تحت المراجعة')
      return Icons.hourglass_empty_rounded;
    return Icons.info_outline;
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
                      size: 14.sp,
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
                      Icon(icon, size: 14.sp, color: statusColor),
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
}
