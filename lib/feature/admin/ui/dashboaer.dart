import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/feature/database_admin/data/models/admin_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/admin_data/admin_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/admin_data/admin_data_state.dart';
import 'package:optialeader/feature/notification/logic/app_notification_cubit.dart';
import 'package:optialeader/feature/notification/ui/notification_page.dart';
import 'package:optialeader/feature/setting/ui/setting.dart';
import 'package:optialeader/feature/database_admin/ui/screens/empolyee_search_page.dart';
import 'package:optialeader/feature/admin/ui/announces/announce.dart';
import 'package:optialeader/core/theming/app_color.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  // ✅ دالة موحدة لتبديل التبويبات
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
          body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeTab(
            currentIndex: _currentIndex,
            onTabTapped: _onTabTapped,
          ),
          _AnnouncementsTab(onBack: () => _onTabTapped(0)),
          const _SearchTab(),
          const _NotificationsTab(),
          // ✅ [تعديل] تمرير دالة الرجوع للتبويب رقم 0 (الرئيسية)
          _SettingsTab(onBackToHome: () => _onTabTapped(0)), 
        ],
      ),
    );
  }
}

/// ============================================================
/// 1. تبويب الصفحة الرئيسية (Home Tab)
/// ============================================================
class _HomeTab extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTabTapped;

  const _HomeTab({required this.currentIndex, required this.onTabTapped});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isArabic = context.locale.languageCode == 'ar';

    return BlocBuilder<AdminDataCubit, AdminDataState>(
      builder: (context, state) {
        if (state is AdminLoading) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.secondary),
          );
        }

        if (state is AdminLoaded) {
          final admin = state.admin!;
          String fullDisplayName = isArabic ? admin.nameAr : admin.nameEn;
          if (fullDisplayName.trim().isEmpty) {
            fullDisplayName = FirebaseAuth.instance.currentUser?.displayName ?? (isArabic ? 'مدير النظام' : 'Admin');
          }

          return SafeArea(
            child: Column(
              children: [
                /// --- الهيدر العلوي ---
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
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
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? 'مرحباً' : 'Welcome',
                              style: TextStyle(
                                color: colorScheme.onPrimary.withOpacity(0.85),
                                fontSize: 16.sp,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              fullDisplayName,
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 22.sp,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.secondary,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 30.r,
                          backgroundColor: colorScheme.surface,
                          child: ClipOval(
                            child: admin.profileImage.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: admin.profileImage,
                                    width: 60.r,
                                    height: 60.r,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (_, __, ___) =>
                                        const Icon(Icons.person),
                                  )
                                : const Icon(Icons.person),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Row(
                    children: isArabic
                        ? [
                            Expanded(child: _buildCardsList(context, state)),
                            _buildSideBar(context),
                          ]
                        : [
                            _buildSideBar(context),
                            Expanded(child: _buildCardsList(context, state)),
                          ],
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

  Widget _buildSideBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: _isExpanded ? 130.w : 55.w,
      margin: EdgeInsets.only(
        left: context.locale.languageCode == 'ar' ? 6.w : 4.w,
        right: context.locale.languageCode == 'ar' ? 4.w : 6.w,
        top: 15.h,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          IconButton(
            icon: Icon(
              _isExpanded ? Icons.menu_open : Icons.menu,
              color: colorScheme.secondary,
              size: 22.sp,
            ),
            onPressed: () => setState(() => _isExpanded = !_isExpanded),
          ),
          SizedBox(height: 5.h),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSideBarItem(Icons.home_outlined, Icons.home, 0, 'الرئيسية', colorScheme, textTheme),
                _buildSideBarItem(Icons.list_alt_outlined, Icons.list_alt, -1, 'الطلبات', colorScheme, textTheme, customAction: () => context.push('/admin/orders-list')),
                _buildSideBarItem(Icons.campaign_outlined, Icons.campaign, 1, 'الإعلانات', colorScheme, textTheme),
                _buildSideBarItem(Icons.search, Icons.search, 2, 'البحث', colorScheme, textTheme),
                _buildSideBarItem(Icons.notifications_none_outlined, Icons.notifications, 3, 'التنبيهات', colorScheme, textTheme),
              ],
            ),
          ),
          _buildSideBarItem(Icons.person_outline, Icons.person, 4, 'الإعدادات', colorScheme, textTheme),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildSideBarItem(
    IconData icon, IconData activeIcon, int index, String label, ColorScheme colorScheme, TextTheme textTheme, {VoidCallback? customAction}
  ) {
    bool isSelected = customAction == null && widget.currentIndex == index;
    final iconColor = isSelected ? colorScheme.secondary : colorScheme.onPrimary.withOpacity(0.8);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Material(
        color: isSelected ? colorScheme.secondary.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: customAction ?? () => widget.onTabTapped(index),
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: _isExpanded ? 8.w : 0),
            alignment: Alignment.center,
            child: _isExpanded
                ? Row(
                    children: [
                      Icon(isSelected ? activeIcon : icon, color: iconColor, size: 20.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          label,
                          style: textTheme.bodySmall?.copyWith(
                            color: iconColor,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Icon(isSelected ? activeIcon : icon, color: iconColor, size: 22.sp),
          ),
        ),
      ),
    );
  }

  Widget _buildCardsList(BuildContext context, AdminLoaded state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(left: 15.w, right: 15.w, top: 0, bottom: 10.h),
      child: Column(
        children: [
          _buildActionCard(context, title: 'dashboard.new_requests'.tr(), icon: Icons.note_add_rounded, value: state.newRequestsCount.toString(), color: colorScheme.primary, onTap: () => context.push('/admin/orders-list')),
          SizedBox(height: 18.h),
          _buildActionCard(context, title: 'dashboard.under_review'.tr(), icon: Icons.gavel_rounded, value: state.underReviewCount.toString(), color: colorScheme.secondary, onTap: () => context.push('/admin/orders-list')),
          SizedBox(height: 18.h),
          _buildActionCard(context, title: 'dashboard.add_announcement'.tr(), icon: Icons.campaign_rounded, value: '+', color: Colors.orange, onTap: () => context.push('/admin/editAnnountmentPage')),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {required String title, required IconData icon, required String value, required Color color, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: 110.h),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: color.withOpacity(0.25), width: 1.5),
          boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 52.w, height: 52.w,
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 26.sp),
            ),
            SizedBox(width: 18.w),
            Expanded(child: Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp))),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(14.r)),
              child: Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color, fontSize: 20.sp)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementsTab extends StatelessWidget {
  final VoidCallback onBack;
  const _AnnouncementsTab({required this.onBack});

  @override
  Widget build(BuildContext context) => AnnouncementsPage(onBack: onBack);
}

// تبويب البحث
class _SearchTab extends StatelessWidget {
  const _SearchTab();
  @override
  Widget build(BuildContext context) => const UserSearchScreen();
}

// تبويب التنبيهات
// تبويب التنبيهات (بقى نضيف لأن الـ Provider متعملش فوق في الـ AppProviders)
class _NotificationsTab extends StatelessWidget {
  const _NotificationsTab();
  
  @override
  Widget build(BuildContext context) {
    // ✅ [تعديل] شيلنا الـ BlocProvider من هنا لأنه بقائي Global في AppProviders
    // بنشغل الـ fetch بمجرد الدخول على التاب ده عشان يجيب أحدث الإشعارات
    context.read<NotificationCubit>().fetchNotifications();
    
    return const NotificationsScreen();
  }
}

// تبويب الإعدادات
class _SettingsTab extends StatelessWidget {
  final VoidCallback onBackToHome; 
  const _SettingsTab({required this.onBackToHome}); 

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AdminDataCubit>().state;
    if (state is AdminLoaded) {
      return SettingsScreen(
        uid: state.admin!.uid, 
        role: 'admin',
        onBack: onBackToHome, 
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}