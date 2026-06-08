import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
// ✅ شلنا import dart:io و image_picker لأنهم مش محتاجين هنا
import 'package:cached_network_image/cached_network_image.dart'; 
import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/feature/database_admin/logic/database_admin_data/database_admin_state.dart';
import 'package:optialeader/feature/database_admin/logic/database_admin_data/databse_admin_cubit.dart';
import 'package:optialeader/core/theming/app_color.dart';
import 'package:optialeader/feature/notification/ui/notification_page.dart';
import 'package:optialeader/feature/setting/ui/setting.dart';

class DatabaseAdminDashboard extends StatefulWidget {
  const DatabaseAdminDashboard({super.key});

  @override
  State<DatabaseAdminDashboard> createState() => _DatabaseAdminDashboardState();
}

class _DatabaseAdminDashboardState extends State<DatabaseAdminDashboard> {
  int _currentIndex = 0;

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

  final List<Widget> _tabs = const [
    _HomeTab(),
    _NotificationsTab(),
    _SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'التنبيهات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}

// تبويب الرئيسية (مربوط بالثيم)
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return BlocBuilder<DatabseAdminCubit, DatabaseAdminState>(
      builder: (context, state) {
        if (state is DatabaseAdminLoading) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: colorScheme.secondary),
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
                    Icon(
                      Icons.error_outline,
                      color: colorScheme.error,
                      size: 60.sp,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "${"dashboard.error".tr()}: ${state.message}",
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.error,
                      ),
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
              title: Row(
                children: [
                  // ✅ [تعديل] الصورة بقيت للعرض فقط بدون GestureDetector وأيقونة الكاميرا
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.secondary,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 28.r,
                      backgroundColor: colorScheme.primaryContainer,
                      child: ClipOval(
                        child: admin.profileImage.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: admin.profileImage,
                                width: 56.r,
                                height: 56.r,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Icon(Icons.person, color: colorScheme.onPrimary, size: 30.sp),
                                errorWidget: (_, __, ___) => Icon(Icons.person, color: colorScheme.onPrimary, size: 30.sp),
                              )
                            : Icon(
                                Icons.person,
                                color: colorScheme.onPrimary,
                                size: 30.sp,
                              ),
                      ),
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
                          style: textTheme.titleLarge?.copyWith(
                            color: colorScheme.onPrimary,
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
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () {},
                ),
                SizedBox(width: 10.w),
              ],
            ),
            body: RefreshIndicator(
              color: colorScheme.secondary,
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
                          state.doctorsCount.toString(),
                          Icons.school,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          context,
                          "dashboard.judges".tr(),
                          state.judgesCount.toString(),
                          Icons.gavel,
                          colorScheme.secondary,
                        ),
                        _buildStatCard(
                          context,
                          "dashboard.admins".tr(),
                          state.adminsCount.toString(),
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
                      colorScheme.primary,
                      Routes.addDoctorPage,
                    ),
                    _buildActionCard(
                      context,
                      "dashboard.add_admin".tr(),
                      Icons.manage_accounts,
                      colorScheme.primaryContainer,
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
            child: CircularProgressIndicator(color: colorScheme.secondary),
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
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.h),
          child: Column(
            children: [
              Icon(icon, color: iconColor, size: 24.sp),
              SizedBox(height: 5.h),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
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
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        margin: EdgeInsets.only(bottom: 15.h),
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: theme.colorScheme.secondary,
              size: 26.sp,
            ),
            SizedBox(width: 15.w),
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: theme.colorScheme.secondary,
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }
}

// 2. تبويب التنبيهات
class _NotificationsTab extends StatelessWidget {
  const _NotificationsTab();
  @override
  Widget build(BuildContext context) {
    final state = context.watch<DatabseAdminCubit>().state;

    if (state is DatabaseAdminSuccess) {
      return const NotificationsScreen();
    }

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

// 3. تبويب الإعدادات
class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DatabseAdminCubit>().state;

    if (state is DatabaseAdminSuccess) {
      return SettingsScreen(uid: state.profile.uid, role: 'database_admin');
    }

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}