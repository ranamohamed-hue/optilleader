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
import 'package:optialeader/core/theming/app_color.dart';

/// ============================================================
/// شاشة الداشبورد الخاصة بالأدمن العادي (Admin)
/// تحتوي على شريط تنقل سفلي مخصص (Sidebar) وهيكل تبويبات (Tabs)
/// ============================================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  /// مؤشر التبويب النشط حالياً (0=الرئيسية، 1=البحث، 2=التنبيهات، 3=الإعدادات)
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // جلب بيانات الأدمن بمجرد فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        context.read<AdminDataCubit>().getAdminProfile(uid);
      }
    });
  }

  /// قائمة بالتبويبات (الصفحات) المعروضة داخل الـ IndexedStack
  final List<Widget> _tabs = const [
    _HomeTab(), // الصفحة الرئيسية (الترحيب والكروت)
    _SearchTab(), // صفحة البحث عن الموظفين
    _NotificationsTab(), // صفحة الإشعارات الخاصة بالأدمن
    _SettingsTab(), // صفحة الإعدادات والتعديل بيانات الأدمن
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      /// الـ body بيستخدم IndexedStack عشان يبدل بين التبويبات من غير ما يفتح صفحات فوق بعضها
      body: IndexedStack(index: _currentIndex, children: _tabs),

      /// الشريط السفلي المخصص (Sidebar) اللي طلبتيه
      bottomNavigationBar: Container(
        height: 70.h,
        color: colorScheme.primary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            /// زرار الصفحة الرئيسية
            IconButton(
              icon: Icon(
                Icons.home_outlined,
                color: _currentIndex == 0 ? AppColors.darkGold : Colors.white,
              ),
              onPressed: () => setState(() => _currentIndex = 0),
            ),

            /// زرار البحث
            IconButton(
              icon: Icon(
                Icons.search,
                color: _currentIndex == 1 ? AppColors.darkGold : Colors.white,
              ),
              onPressed: () => setState(() => _currentIndex = 1),
            ),

            /// زرار التنبيهات
            IconButton(
              icon: Icon(
                Icons.notifications_none_outlined,
                color: _currentIndex == 2 ? AppColors.darkGold : Colors.white,
              ),
              onPressed: () => setState(() => _currentIndex = 2),
            ),

            /// زرار البروفايل/الإعدادات
            IconButton(
              icon: Icon(
                Icons.person_outline,
                color: _currentIndex == 3 ? AppColors.darkGold : Colors.white,
              ),
              onPressed: () => setState(() => _currentIndex = 3),
            ),

            /// زرار تسجيل الخروج (أحمر دايماً لأنه Action مش Tab)
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
/// 1. تبويب الصفحة الرئيسية (Home Tab)
/// بيعرض هيدر بالترحيب واسم الأدمن، وكروت للإجراءات السريعة
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
        /// حالة التحميل
        if (state is AdminLoading) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.secondary),
          );
        }

        /// حالة نجاح جلب البيانات (عرض الواجهة)
        if (state is AdminLoaded) {
          // ✅ شلنا علامة التعجب (!) عشان الـ state اللي عملناه مش Nullable
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
                        /// كارت الطلبات الجديدة (الرقم ديناميكي من الـ State)
                        _buildActionCard(
                          context,
                          title: 'dashboard.new_requests'.tr(),
                          icon: Icons.note_add_rounded,
                          value: state.newRequestsCount
                              .toString(), // ✅ ديناميكي
                          color: colorScheme.primary,
                        ),
                        SizedBox(height: 15.h),

                        /// كارت الطلبات تحت المراجعة (الرقم ديناميكي من الـ State)
                        _buildActionCard(
                          context,
                          title: 'dashboard.under_review'.tr(),
                          icon: Icons.gavel_rounded,
                          value: state.underReviewCount
                              .toString(), // ✅ ديناميكي
                          color: colorScheme.secondary,
                        ),
                        SizedBox(height: 15.h),

                        /// كارت إضافة إعلان جديد
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

        /// حالة خطأ جلب البيانات
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

  /// ويدجت مساعدة لبناء كروت الإجراءات السريعة
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
