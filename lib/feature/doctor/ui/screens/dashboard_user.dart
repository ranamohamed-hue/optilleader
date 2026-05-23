import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
class DashboardUserPage extends StatelessWidget {
  const DashboardUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryNavy = theme.colorScheme.primary;
    final goldAccent = theme.colorScheme.secondary;
    final scaffoldBg = theme.scaffoldBackgroundColor;

    return BlocBuilder<DoctorDataCubit, DoctorDataState>(
      builder: (context, state) {
        // 1. حالة التحميل
        if (state is DoctorLoading) {
          return Scaffold(
            backgroundColor: scaffoldBg,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // 2. حالة عرض البيانات (DoctorLoaded)
        if (state is DoctorLoaded) {
          final doctor = state.doctor;

          return Scaffold(
            backgroundColor: scaffoldBg,
            appBar: AppBar(
              backgroundColor: primaryNavy,
              elevation: 0,
              toolbarHeight: 85.h,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  size: 20.sp,
                  color: Colors.white,
                ),
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
                  _buildProfileAvatar(goldAccent, doctor?.profileImage),
                  SizedBox(width: 12.w),
                  _buildWelcomeText(
                    context.locale.languageCode == 'ar'
                        ? (doctor?.nameAr ?? 'dashboard.doctor_default'.tr())
                        : (doctor?.nameEn ?? 'dashboard.doctor_default'.tr()),
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(4.h),
                child: Container(color: goldAccent, height: 3.h),
              ),
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                if (doctor?.uid != null) {
                  await context.read<DoctorDataCubit>().getDoctorProfile(
                    doctor!.uid!,
                  );
                }
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 15.w,
                      mainAxisSpacing: 15.h,
                      childAspectRatio: 1.1,
                      children: [
                        _buildStatCard(
                          'dashboard.achievements'.tr(),
                          Icons.emoji_events_outlined,
                          goldAccent,
                          'dashboard.achievements_msg'.tr(
                            args: [
                              (doctor?.academicHistory.length ?? 0).toString(),
                            ],
                          ),
                          primaryNavy,
                        ),
                        _buildStatCard(
                          'dashboard.academic_data'.tr(),
                          Icons.school_outlined,
                          goldAccent,
                          (doctor?.academicHistory != null &&
                                  doctor!.academicHistory.isNotEmpty)
                              ? (context.locale.languageCode == 'ar'
                                    ? (doctor
                                              .academicHistory
                                              .first['degree_ar'] ??
                                          'لا يوجد مؤهل')
                                    : (doctor
                                              .academicHistory
                                              .first['degree_en'] ??
                                          'No Degree'))
                              : 'dashboard.no_credentials'.tr(),
                          primaryNavy,
                        ),
                        _buildStatusCard(
                          'dashboard.requests_status'.tr(),
                          '3', // يمكن ربطها بـ doctor?.notifications.length
                          'dashboard.pending'.tr(),
                          Colors.red.shade50,
                          Colors.red.shade900,
                        ),
                        _buildProgressCard(
                          'dashboard.career_path'.tr(),
                          0.75,
                          primaryNavy,
                          goldAccent,
                        ),
                      ],
                    ),
                    SizedBox(height: 30.h),
                    _buildSectionTitle(
                      primaryNavy,
                      goldAccent,
                      'dashboard.latest_opportunities'.tr(),
                    ),
                    SizedBox(height: 10.h),
                    _buildOpportunityItem(
                      'dashboard.opp1_title'.tr(),
                      'dashboard.opp1_desc'.tr(),
                      Icons.campaign_outlined,
                      primaryNavy.withOpacity(0.05),
                      primaryNavy,
                      goldAccent,
                    ),
                    SizedBox(height: 12.h),
                    _buildOpportunityItem(
                      'dashboard.opp2_title'.tr(),
                      'dashboard.opp2_desc'.tr(),
                      Icons.analytics_outlined,
                      primaryNavy.withOpacity(0.05),
                      primaryNavy,
                      goldAccent,
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: _buildBottomNav(primaryNavy, goldAccent),
          );
        }

        // 3. حالة الخطأ
        if (state is DoctorError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48.sp),
                  SizedBox(height: 16.h),
                  Text(
                    state.error ?? 'error_message'.tr(),
                    style: TextStyle(color: Colors.red, fontSize: 14.sp),
                  ),
                  SizedBox(height: 20.h),
                  ElevatedButton(
                    onPressed: () {}, // استدعاء دالة التحميل مرة أخرى هنا
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            ),
          );
        }

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  // --- المكونات الفرعية (Widgets) ---

  Widget _buildProfileAvatar(Color gold, String? imageUrl) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: gold, width: 1.5),
      ),
      child: CircleAvatar(
        radius: 22.r,
        backgroundColor: Colors.white10,
        // ✅ [تعديل] استخدام CachedNetworkImageProvider بدل NetworkImage
        backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
            ? CachedNetworkImageProvider(imageUrl) 
            : null,
        child: (imageUrl == null || imageUrl.isEmpty)
            ? Icon(Icons.person, color: gold, size: 26.sp)
            : null,
      ),
    );
  }

  Widget _buildWelcomeText(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'dashboard.welcome'.tr(),
          style: TextStyle(color: Colors.white70, fontSize: 10.sp),
        ),
        Text(
          name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(Color navy, Color gold, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4.w,
              height: 18.h,
              decoration: BoxDecoration(
                color: gold,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'dashboard.view_all'.tr(),
            style: TextStyle(
              color: gold,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    IconData icon,
    Color gold,
    String content,
    Color navy,
  ) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: gold.withOpacity(0.3), width: 1.2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: gold, size: 18.sp),
              SizedBox(width: 5.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: navy,
                    fontSize: 12.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            content,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 10.sp,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    String title,
    String count,
    String label,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
              fontSize: 11.sp,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(color: textColor, fontSize: 9.sp),
                  ),
                ],
              ),
              Icon(
                Icons.notifications_active_outlined,
                color: textColor.withOpacity(0.4),
                size: 22.sp,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
    String title,
    double progress,
    Color navy,
    Color gold,
  ) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: navy.withOpacity(0.1), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: navy,
              fontSize: 12.sp,
            ),
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: navy.withOpacity(0.05),
              color: gold,
              minHeight: 6.h,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'dashboard.completed_percent'.tr(
              args: ['${(progress * 100).toInt()}%'],
            ),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11.sp,
              color: navy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpportunityItem(
    String title,
    String subtitle,
    IconData icon,
    Color iconBg,
    Color navy,
    Color gold,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: gold.withOpacity(0.15), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: navy, size: 22.sp),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: navy,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey, fontSize: 10.sp),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 12.sp, color: gold),
        ],
      ),
    );
  }

  Widget _buildBottomNav(Color navy, Color gold) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: gold,
      unselectedItemColor: Colors.grey.shade400,
      currentIndex: 3,
      backgroundColor: Colors.white,
      elevation: 25,
      selectedFontSize: 10.sp,
      unselectedFontSize: 10.sp,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings_outlined),
          label: 'dashboard.nav.settings'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.notifications_none),
          label: 'dashboard.nav.notifications'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.folder_open_outlined),
          label: 'dashboard.nav.files'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_filled),
          label: 'dashboard.nav.home'.tr(),
        ),
      ],
    );
  }
}
