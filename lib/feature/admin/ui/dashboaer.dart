import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart'; // إضافة سطر استيراد الترجمة

import 'package:optialeader/feature/database_admin/data/models/admin_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/admin_data/admin_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/admin_data/admin_data_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BlocListener<AdminDataCubit, AdminDataState>(
      listener: (context, state) {
        if (state is AdminError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: BlocBuilder<AdminDataCubit, AdminDataState>(
          builder: (context, state) {
            // 1. حالة التحميل
            if (state is AdminLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. حالة نجاح جلب البيانات (AdminLoaded)
            if (state is AdminLoaded && state.admin != null) {
              final admin = state.admin!;

              return SafeArea(
                child: Column(
                  children: [
                    _buildHeader(colorScheme, textTheme, admin),

                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.symmetric(vertical: 20.h),
                                child: Column(
                                  children: [
                                    _buildDetailedCard(
                                      context,
                                      title: 'dashboard.new_requests'
                                          .tr(), // ربط مفتاح الترجمة
                                      value:
                                          '15', // القيمة عادة تأتي من API ولكن وضعنا مفتاح للعنوان
                                      icon: Icons.note_add_rounded,
                                      bgColor:
                                          theme.cardTheme.color ?? Colors.white,
                                      onTap: () =>
                                          context.push('/admin/orders-list'),
                                    ),
                                    SizedBox(height: 15.h),
                                    _buildDetailedCard(
                                      context,
                                      title: 'dashboard.under_review'
                                          .tr(), // ربط مفتاح الترجمة
                                      value: '08',
                                      icon: Icons.gavel_rounded,
                                      bgColor: colorScheme.secondary
                                          .withOpacity(0.2),
                                      onTap: () =>
                                          context.push('/admin/orders-list'),
                                    ),
                                    SizedBox(height: 15.h),
                                    _buildDetailedCard(
                                      context,
                                      title: 'dashboard.add_announcement'
                                          .tr(), // ربط مفتاح الترجمة
                                      value: '+',
                                      icon: Icons.campaign_rounded,
                                      bgColor: colorScheme.primary.withOpacity(
                                        0.1,
                                      ),
                                      onTap: () =>
                                          context.push('/admin/announcements'),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(width: 15.w),

                            _buildSidebar(context, colorScheme),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // 3. حالة الخطأ أو البداية
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("dashboard.no_data".tr()), // ربط مفتاح الترجمة
                  SizedBox(height: 10.h),
                  ElevatedButton(
                    onPressed: () {
                      // context.read<AdminDataCubit>().getAdminProfile(currentUid);
                    },
                    child: Text("dashboard.retry".tr()), // ربط مفتاح الترجمة
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// بناء الـ Header
  Widget _buildHeader(
    ColorScheme colorScheme,
    TextTheme textTheme,
    AdminProfileModel admin,
  ) {
    return Container(
      padding: EdgeInsets.all(25.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.primaryContainer],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30.r)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'dashboard.welcome'.tr(
                  args: [admin.nameAr],
                ), // استخدام الترجمة مع تمرير الاسم كمتغير
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onPrimary,
                ),
              ),
              Text(
                admin.jobAr.isNotEmpty
                    ? admin.jobAr
                    : "dashboard.system_admin"
                          .tr(), // ربط المسمى الوظيفي الافتراضي
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimary.withOpacity(0.8),
                ),
              ),
            ],
          ),
          _buildAvatar(colorScheme, admin.profileImage),
        ],
      ),
    );
  }

  /// بناء الـ Avatar
  Widget _buildAvatar(ColorScheme colorScheme, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colorScheme.secondary, width: 2),
      ),
      child: CircleAvatar(
        radius: 28.r,
        backgroundColor: colorScheme.surface,
        child: ClipOval(
          child: imageUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: 56.r,
                  height: 56.r,
                  placeholder: (_, __) =>
                      const CircularProgressIndicator(strokeWidth: 2),
                  errorWidget: (_, __, ___) => const Icon(Icons.person),
                )
              : const Icon(Icons.person),
        ),
      ),
    );
  }

  /// بناء الـ Sidebar
  Widget _buildSidebar(BuildContext context, ColorScheme colorScheme) {
    return Container(
      width: 60.w,
      margin: EdgeInsets.symmetric(vertical: 20.h),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _sideBarIcon(
            Icons.person_outline,
            () => context.push('/admin/admin_setting'),
          ),
          _sideBarIcon(
            Icons.search_rounded,
            () => context.push('/admin/user_search'),
          ),
          _sideBarIcon(Icons.notifications_none, () {}),
          _sideBarIcon(Icons.logout, () {
            // منطق تسجيل الخروج
          }, color: Colors.redAccent),
        ],
      ),
    );
  }

  Widget _sideBarIcon(IconData icon, VoidCallback onTap, {Color? color}) {
    return IconButton(
      icon: Icon(icon, size: 24.sp),
      color: color ?? Colors.white.withOpacity(0.7),
      onPressed: onTap,
    );
  }

  /// بناء الـ Card المطور
  Widget _buildDetailedCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: theme.brightness == Brightness.light
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Icon(
                  icon,
                  size: 35.sp,
                  color: theme.colorScheme.primary.withOpacity(0.2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
