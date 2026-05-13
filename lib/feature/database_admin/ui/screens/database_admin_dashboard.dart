import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/feature/database_admin/logic/database_admin_data/database_admin_state.dart';
import 'package:optialeader/feature/database_admin/logic/database_admin_data/databse_admin_cubit.dart';
import 'package:optialeader/core/theming/app_color.dart';

class DatabaseAdminDashboard extends StatefulWidget {
  const DatabaseAdminDashboard({super.key});

  @override
  State<DatabaseAdminDashboard> createState() => _DatabaseAdminDashboardState();
}

class _DatabaseAdminDashboardState extends State<DatabaseAdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        context.read<DatabseAdminCubit>().getProfile(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return BlocBuilder<DatabseAdminCubit, DatabaseAdminState>(
      builder: (context, state) {
        if (state is DatabaseAdminLoading) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.darkGold),
            ),
          );
        }

        if (state is DatabaseAdminError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 60.sp),
                    SizedBox(height: 10.h),
                    Text(
                      "${"dashboard.error".tr()}: ${state.message}",
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is DatabaseAdminSuccess) {
          final admin = state.profile;
          final isArabic = context.locale.languageCode == 'ar';

          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 90.h,
              backgroundColor: AppColors.navyDark,
              title: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.darkGold, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 28.r,
                      backgroundColor: AppColors.navyLight,
                      backgroundImage: admin.profileImage.isNotEmpty
                          ? NetworkImage(admin.profileImage)
                          : null,
                      child: admin.profileImage.isEmpty
                          ? Icon(Icons.person, color: Colors.white, size: 30.sp)
                          : null,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "dashboard.welcome".tr(),
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          isArabic ? admin.nameAr : admin.nameEn,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
                SizedBox(width: 10.w),
              ],
            ),
            body: RefreshIndicator(
              color: AppColors.darkGold,
              onRefresh: () async =>
                  await context.read<DatabseAdminCubit>().getProfile(admin.uid),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "dashboard.system_overview".tr(),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Row(
                      children: [
                        _buildStatCard(
                          context,
                          "dashboard.doctors".tr(),
                          "25",
                          Icons.school,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          context,
                          "dashboard.judges".tr(),
                          "12",
                          Icons.gavel,
                          AppColors.darkGold,
                        ),
                        _buildStatCard(
                          context,
                          "dashboard.admins".tr(),
                          "8",
                          Icons.admin_panel_settings,
                          Colors.green,
                        ),
                      ],
                    ),
                    SizedBox(height: 35.h),
                    Text(
                      "dashboard.manage_data".tr(),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 15.h),
                    _buildActionCard(
                      context,
                      "dashboard.search".tr(),
                      Icons.person_search,
                      Colors.teal,
                      Routes.searchPage,
                    ),
                    _buildActionCard(
                      context,
                      "dashboard.add_doctor".tr(),
                      Icons.person_add_alt_1,
                      AppColors.navyDark,
                      Routes.addDoctorPage,
                    ),
                    _buildActionCard(
                      context,
                      "dashboard.add_admin".tr(),
                      Icons.manage_accounts,
                      AppColors.navyLight,
                      Routes.addAdminPage,
                    ),
                    _buildActionCard(
                      context,
                      "dashboard.add_judge".tr(),
                      Icons.verified_user,
                      const Color(0xFF1A1A3F),
                      Routes.addJudgePage,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: AppColors.darkGold),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.h),
          child: Column(
            children: [
              Icon(icon, color: iconColor, size: 24.sp),
              SizedBox(height: 5.h),
              Text(
                value,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10.sp, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color bgColor,
    String route,
  ) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        margin: EdgeInsets.only(bottom: 15.h),
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.darkGold, size: 26.sp),
            SizedBox(width: 15.w),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15.sp,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.darkGold,
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }
}
