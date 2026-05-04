import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart'; // إضافة الترجمة
import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/feature/database_admin/logic/database_admin_data/database_admin_state.dart';
import 'package:optialeader/feature/database_admin/logic/database_admin_data/databse_admin_cubit.dart';
import 'package:optialeader/core/theming/app_color.dart';

class DatabaseAdminDashboard extends StatelessWidget {
  const DatabaseAdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
              child: Text(
                "${"dashboard.error".tr()}: ${state.message}",
                style: textTheme.bodyLarge?.copyWith(color: colorScheme.error),
              ),
            ),
          );
        }

        if (state is DatabaseAdminSuccess) {
          final admin = state.profile;

          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 80.h,
              title: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.darkGold, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 25.r,
                      backgroundColor: AppColors.navyLight,
                      backgroundImage: admin.profileImage.isNotEmpty
                          ? NetworkImage(admin.profileImage)
                          : null,
                      child: admin.profileImage.isEmpty
                          ? Icon(Icons.person, color: Colors.white, size: 30.sp)
                          : null,
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "dashboard.welcome".tr(),
                        style: textTheme.bodySmall,
                      ),
                      Text(
                        admin
                            .nameAr, // تقدري تستخدمي admin.nameEn حسب لغة التطبيق
                        style: theme.appBarTheme.titleTextStyle,
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () {},
                ),
                SizedBox(width: 10.w),
              ],
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
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
                  SizedBox(height: 40.h),
                  Text(
                    "dashboard.manage_data".tr(),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15.h),
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
                    const Color(0xFF1A1A3F), // كحلي ملكي أغمق
                    Routes.addJudgePage,
                  ),
                ],
              ),
            ),
          );
        }
        return const Scaffold();
      },
    );
  }

  // --- Widgets المساعدة ---
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
              SizedBox(height: 8.h),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
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
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: AppColors.darkGold.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.darkGold, size: 28.sp),
            SizedBox(width: 20.w),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.darkGold,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
