import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart'; // ✅ مهم جداً للانتقالات الجديدة

import 'package:optialeader/feature/admin/logic/admin_cubit.dart';
import 'package:optialeader/feature/admin/logic/admin_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BlocListener<AdminCubit, AdminState>(
      listener: (context, state) {
        if (state is AdminSuccess && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message!)),
          );
        }
      },
      child: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is AdminError) {
            return Scaffold(
              body: Center(
                child: Text(state.error, style: textTheme.bodyLarge),
              ),
            );
          }

          if (state is AdminSuccess) {
            final admin = state.admin;

            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              body: SafeArea(
                child: Column(
                  children: [
                    /// 🔵 Header 
                    _buildHeader(colorScheme, textTheme, admin),

                    /// 🟢 Content
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          children: [
                            /// 🔵 Dashboard Cards (الجزء المخصص للكروت)
                            Expanded(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.symmetric(vertical: 20.h),
                                child: Column(
                                  children: [
                                    _buildDetailedCard(
                                      context,
                                      title: 'طلبات جديدة',
                                      value: '15',
                                      icon: Icons.note_add_rounded,
                                      bgColor: theme.cardTheme.color!,
                                      // ✅ الانتقال لصفحة الطلبات
                                      onTap: () => context.push('/admin/orders-list'),
                                    ),
                                    SizedBox(height: 15.h),
                                    _buildDetailedCard(
                                      context,
                                      title: 'قيد التحكيم',
                                      value: '08',
                                      icon: Icons.gavel_rounded,
                                      bgColor: colorScheme.secondary.withOpacity(0.2),
                                      // ✅ الانتقال لنفس الصفحة (أو صفحة مخصصة للتحكيم لاحقاً)
                                      onTap: () => context.push('/admin/orders-list'),
                                    ),
                                    SizedBox(height: 15.h),
                                    _buildDetailedCard(
                                      context,
                                      title: 'إضافة إعلان',
                                      value: '+',
                                      icon: Icons.campaign_rounded,
                                      bgColor: colorScheme.primary.withOpacity(0.1),
                                      // ✅ الانتقال لصفحة الإعلانات
                                      onTap: () => context.push('/admin/announcements'),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(width: 15.w),

                            /// 🔵 Sidebar Navigation (الشريط الجانبي)
                            _buildSidebar(context, colorScheme),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Scaffold();
        },
      ),
    );
  }

  /// 🛠️ بناء الـ Header
  Widget _buildHeader(ColorScheme colorScheme, TextTheme textTheme, var admin) {
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
                'Welcome, ${admin.username}',
                style: textTheme.titleLarge?.copyWith(color: colorScheme.onPrimary),
              ),
              Text(
                admin.info.jobTitleAr.isNotEmpty ? admin.info.jobTitleAr : "إداري النظام",
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimary.withOpacity(0.8),
                ),
              ),
            ],
          ),
          _buildAvatar(colorScheme, admin.info.profileImage),
        ],
      ),
    );
  }

  /// 🛠️ بناء الـ Avatar
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
                  placeholder: (_, __) => const CircularProgressIndicator(),
                  errorWidget: (_, __, ___) => const Icon(Icons.person),
                )
              : const Icon(Icons.person),
        ),
      ),
    );
  }

  /// 🛠️ بناء الـ Sidebar مع الانتقالات الجديدة
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
            () => context.push('/admin/admin_setting'), // ✅ تحديث المسار
          ),
          _sideBarIcon(
            Icons.search_rounded,
            () => context.push('/admin/user_search'), // ✅ تحديث المسار
          ),
          _sideBarIcon(Icons.notifications_none, () {}),
          _sideBarIcon(
            Icons.logout, 
            () {
              // هنا تقدري تنادي ميثود تسجيل الخروج من الـ Cubit
            }, 
            color: Colors.redAccent
          ),
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

  /// 🛠️ بناء الـ Card المطور مع خاصية الـ Click
  Widget _buildDetailedCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color bgColor,
    required VoidCallback onTap, // ✅ ضفنا الـ onTap كباراميتر أساسي
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap, // ✅ تفعيل الضغطة
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: theme.brightness == Brightness.light
              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
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