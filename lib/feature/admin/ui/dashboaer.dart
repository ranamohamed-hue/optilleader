import 'dart:io'; // ✅ [مهم] لإدارة كائن File
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart'; // ✅ [مهم] لاختيار الصور من المعرض
import 'package:optialeader/feature/database_admin/data/models/admin_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/admin_data/admin_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/admin_data/admin_data_state.dart';
import 'package:optialeader/feature/notification/logic/app_notification_cubit.dart';
import 'package:optialeader/feature/notification/ui/notification_page.dart';
import 'package:optialeader/feature/setting/ui/setting.dart';
import 'package:optialeader/feature/database_admin/ui/screens/empolyee_search_page.dart';
import 'package:optialeader/core/theming/app_color.dart';

/// ============================================================
/// شاشة الداشبورد الخاصة بالأدمن العادي (Admin)
/// ============================================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        context.read<AdminDataCubit>().getAdminProfile(uid);
      }
    });
  }

  final List<Widget> _tabs = const [
    _HomeTab(),
    _SearchTab(),
    _NotificationsTab(),
    _SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: Container(
        height: 70.h,
        color: colorScheme.primary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(
                Icons.home_outlined,
                color: _currentIndex == 0 ? AppColors.darkGold : Colors.white,
              ),
              onPressed: () => setState(() => _currentIndex = 0),
            ),
            IconButton(
              icon: Icon(
                Icons.search,
                color: _currentIndex == 1 ? AppColors.darkGold : Colors.white,
              ),
              onPressed: () => setState(() => _currentIndex = 1),
            ),
            IconButton(
              icon: Icon(
                Icons.notifications_none_outlined,
                color: _currentIndex == 2 ? AppColors.darkGold : Colors.white,
              ),
              onPressed: () => setState(() => _currentIndex = 2),
            ),
            IconButton(
              icon: Icon(
                Icons.person_outline,
                color: _currentIndex == 3 ? AppColors.darkGold : Colors.white,
              ),
              onPressed: () => setState(() => _currentIndex = 3),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// 1. تبويب الصفحة الرئيسية (Home Tab) - تم تعديله لإضافة رفع الصورة
/// ============================================================
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BlocBuilder<AdminDataCubit, AdminDataState>(
      builder: (context, state) {
        if (state is AdminLoading) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.secondary),
          );
        }

        if (state is AdminLoaded) {
          final admin = state.admin!;
          bool isArabic = context.locale.languageCode == 'ar';
          String displayName = isArabic ? admin.nameAr : admin.nameEn;
          String displayJob = isArabic ? admin.jopAr : admin.jopEn;

          return SafeArea(
            child: Column(
              children: [
                /// --- الهيدر العلوي (Header) ---
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(25.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary,
                        colorScheme.primaryContainer,
                      ],
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'dashboard.welcome'.tr(args: [displayName]),
                              style: textTheme.titleLarge?.copyWith(
                                color: colorScheme.onPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              displayJob.isNotEmpty
                                  ? displayJob
                                  : 'dashboard.system_admin'.tr(),
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onPrimary.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ✅ [تعديل] تحويل الصورة إلى زر قابل للنقر لرفع صورة جديدة
                      GestureDetector(
                        onTap: () async {
                          // 1. فتح معرض الصور
                          final ImagePicker picker = ImagePicker();
                          final XFile? pickedFile = await picker.pickImage(
                            source: ImageSource.gallery,
                            requestFullMetadata: false,
                          );

                          // 2. إذا اختار صورة، نرفعها عبر الكيوبت
                          if (pickedFile != null) {
                            if (context.mounted) {
                              context
                                  .read<AdminDataCubit>()
                                  .updateAdminProfileImage(
                                    admin.uid,
                                    File(pickedFile.path),
                                  );
                            }
                          }
                        },
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 28.r,
                              backgroundColor: colorScheme.surface,
                              child: ClipOval(
                                child: admin.profileImage.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: admin.profileImage,
                                        width: 56.r,
                                        height: 56.r,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) =>
                                            const CircularProgressIndicator(),
                                        errorWidget: (_, __, ___) =>
                                            const Icon(Icons.person),
                                      )
                                    : const Icon(Icons.person),
                              ),
                            ),
                            // ✅ أيقونة الكاميرا الصغيرة فوق الصورة
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(4.r),
                                decoration: BoxDecoration(
                                  color: AppColors.darkGold,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 14.r,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            // ✅ مؤشر تحميل يظهر فوق الصورة أثناء الرفع لـ Supabase
                            if (state
                                is AdminLoading) // يمكنك تعديل هذا إذا كان لديك State مخصص للتحميل
                              Container(
                                width: 56.r,
                                height: 56.r,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: 20.r,
                                    height: 20.r,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.r,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                /// --- محتوى الصفحة (الكروت) ---
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        _buildActionCard(
                          context,
                          title: 'dashboard.new_requests'.tr(),
                          icon: Icons.note_add_rounded,
                          value: state.newRequestsCount.toString(),
                          color: colorScheme.primary,
                        ),
                        SizedBox(height: 15.h),
                        _buildActionCard(
                          context,
                          title: 'dashboard.under_review'.tr(),
                          icon: Icons.gavel_rounded,
                          value: state.underReviewCount.toString(),
                          color: colorScheme.secondary,
                        ),
                        SizedBox(height: 15.h),
                        _buildActionCard(
                          context,
                          title: 'dashboard.add_announcement'.tr(),
                          icon: Icons.campaign_rounded,
                          value: '+',
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is AdminError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.error, style: TextStyle(color: colorScheme.error)),
                SizedBox(height: 10.h),
                ElevatedButton(
                  onPressed: () {
                    final uid = FirebaseAuth.instance.currentUser?.uid ?? "";
                    context.read<AdminDataCubit>().getAdminProfile(uid);
                  },
                  child: Text('dashboard.retry'.tr()),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 10.w),
              Icon(icon, color: color),
            ],
          ),
        ],
      ),
    );
  }
}

// تبويب البحث (Search Tab)
class _SearchTab extends StatelessWidget {
  const _SearchTab();
  @override
  Widget build(BuildContext context) {
    return const EmployeeSearchScreen();
  }
}

// تبويب التنبيهات (Notifications Tab)
class _NotificationsTab extends StatelessWidget {
  const _NotificationsTab();
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          NotificationCubit(userRole: 'admin')..fetchNotifications(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التنبيهات'),
          automaticallyImplyLeading: false,
        ),
        body: const NotificationsScreen(),
      ),
    );
  }
}

// تبويب الإعدادات (Settings Tab)
class _SettingsTab extends StatelessWidget {
  const _SettingsTab();
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AdminDataCubit>().state;
    if (state is AdminLoaded) {
      return SettingsScreen(uid: state.admin!.uid, role: 'admin');
    }
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
