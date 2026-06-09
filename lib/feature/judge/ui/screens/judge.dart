import 'dart:ui' as ui; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:optialeader/core/routing/routes.dart'; 
import 'package:optialeader/feature/database_admin/logic/judge_data/judge_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/judge_data/judge_data_state.dart';
import 'package:optialeader/feature/notification/logic/app_notification_cubit.dart'; // ✅ [إضافة] استدعاء لـ NotificationCubit

class MohakemDashboardHome extends StatefulWidget {
  const MohakemDashboardHome({super.key});

  @override
  State<MohakemDashboardHome> createState() => _MohakemDashboardHomeState();
}

class _MohakemDashboardHomeState extends State<MohakemDashboardHome> {
  @override
  void initState() {
    super.initState();
    // ✅ [تعديل] استخدام addPostFrameCallback لتجنب مشاكل الـ context في initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        context.read<JudgeDataCubit>().getJudgeProfile(uid);
        // ✅ [إضافة] جلب الإشعارات مرة واحدة في الخلفية
        context.read<NotificationCubit>().fetchNotifications();
      }

      // ✅ [إضافة] فحص هل هو أول تسجيل دخول لعرض الديالوج الترحيبي
      _checkAndShowWelcomeDialog();
    });
  }

  // ✅ [إضافة] دالة فحص أول تسجيل دخول
  void _checkAndShowWelcomeDialog() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final creationTime = user.metadata.creationTime;
    final lastSignInTime = user.metadata.lastSignInTime;

    if (creationTime != null && lastSignInTime != null) {
      final difference = lastSignInTime.difference(creationTime).inMinutes;
      if (difference < 2) {
        _showWelcomeDialog();
      }
    }
  }

  // ✅ [إضافة] تصميم الديالوج الترحيبي المشترك
  void _showWelcomeDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    final isArabic = context.locale.languageCode == 'ar';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Icon(Icons.waving_hand_rounded, color: Colors.orange, size: 28.sp),
            SizedBox(width: 10.w),
            Text(
              isArabic ? 'أهلاً بك!' : 'Welcome!',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          isArabic
              ? 'يسعدنا انضمامك لمنصة OptiLeader.\nيمكنك البدء في استكشاف الميزات الخاصة بك من القائمة.'
              : 'Welcome to OptiLeader platform.\nYou can start exploring your features from the menu.',
          style: TextStyle(fontSize: 15.sp, height: 1.5),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                isArabic ? 'لنبدأ!' : "Let's Start!",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorPrimary = theme.colorScheme.primary;
    final colorGold = theme.colorScheme.secondary;

    return BlocBuilder<JudgeDataCubit, JudgeDataState>(
      builder: (context, state) {
        if (state is JudgeInitial || state is JudgeLoading) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: colorGold),
            ),
          );
        }

        if (state is JudgeError) {
          return Scaffold(
            body: Center(
              child: Text(
                state.error ?? "Error",
                style: TextStyle(fontFamily: 'Tajawal', fontSize: 16.sp),
              ),
            ),
          );
        }

        if (state is JudgeLoaded) {
          final judge = state.judge!;
          final isArabic = context.locale.languageCode == 'ar';

          final displayName = isArabic
              ? (judge.nameAr.isNotEmpty ? judge.nameAr : "محكم")
              : (judge.nameEn.isNotEmpty ? judge.nameEn : "Judge");

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Column(
              children: [
                // 1 الهيدر الكحلي
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorPrimary,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30.r),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        _buildHeaderRow(context, colorGold, displayName, judge.profileImage),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
                
                // 2 الخط الدهبي الفاصل
                Container(
                  width: double.infinity,
                  height: 3.0,
                  color: colorGold,
                ),

                // 3 محتوى الصفحة
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 25.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'dashboardJudge.system_overview'.tr(),
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: colorPrimary,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        SizedBox(height: 15.h),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                context,
                                'dashboardJudge.cards.under_review'.tr(),
                                "24",
                                Icons.pending_actions,
                                true,
                              ),
                            ),
                            SizedBox(width: 15.w),
                            Expanded(
                              child: _buildStatCard(
                                context,
                                'orders.status_approved'.tr(),
                                "156",
                                Icons.verified,
                                false,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30.h),
                        _buildSectionTitle(
                          colorGold,
                          colorPrimary,
                          'orders.report_title'.tr(),
                        ),
                        SizedBox(height: 12.h),
                        _buildApplicantItem(
                          context,
                          isArabic ? 'سعود صالح القحطاني' : 'Saud Al-Qahtani',
                          isArabic ? judge.jopAr : judge.jopEn,
                          true,
                        ),
                        _buildApplicantItem(
                          context,
                          isArabic ? 'نورة عبد الرحمن' : 'Noura Abdulrahman',
                          isArabic
                              ? 'قسم الفيزياء التطبيقية'
                              : 'Applied Physics Dept',
                          false,
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            //  تمرير الـ uid والـ role للـ BottomNav
            bottomNavigationBar: _buildBottomNav(colorPrimary, colorGold, judge.uid, judge.role),
          );
        }

        return const Scaffold(body: SizedBox.shrink());
      },
    );
  }

  //  Row موحد للسهم والاسم في جهة، والصورة في الجهة التانية
  Widget _buildHeaderRow(
    BuildContext context,
    Color gold,
    String name,
    String? imageUrl,
  ) {
    final isArabic = context.locale.languageCode == 'ar';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Row(
        textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        children: [
          // الجهة الأولى: السهم + النص
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 20.sp,
              color: Colors.white,
            ),
            onPressed: () => context.canPop() ? context.pop() : null,
          ),
          SizedBox(width: 5.w),
          Expanded(
            child: Text(
              'dashboardJudge.welcome'.tr(args: [name]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
          SizedBox(width: 15.w),
          
          // الجهة الثانية: الصورة الشخصية
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: gold, width: 3.w),
            ),
            child: CircleAvatar(
              radius: 28.r,
              backgroundColor: Colors.white.withOpacity(0.15),
              child: ClipOval(
                child: (imageUrl != null && imageUrl.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 56.r,
                        height: 56.r,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Icon(Icons.person, color: gold, size: 30.sp),
                        errorWidget: (_, __, ___) =>
                            Icon(Icons.person, color: gold, size: 30.sp),
                      )
                    : Icon(Icons.person, color: gold, size: 30.sp),
              ),
            ),
          ),     ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String count,
    IconData icon,
    bool isGold,
  ) {
    final gold = Theme.of(context).colorScheme.secondary;
    final navy = Theme.of(context).colorScheme.primary;
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isGold ? gold : Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: isGold ? Colors.white : gold, size: 24.sp),
          SizedBox(height: 12.h),
          Text(
            count,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: isGold ? Colors.white : navy,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10.sp,
              fontFamily: 'Tajawal',
              color: isGold ? Colors.white70 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(Color gold, Color navy, String title) {
    return Row(
      children: [
        Container(
          width: 5.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: gold,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: navy,
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }

  Widget _buildApplicantItem(
    BuildContext context,
    String name,
    String info,
    bool needsAction,
  ) {
    final navy = Theme.of(context).colorScheme.primary;
    final gold = Theme.of(context).colorScheme.secondary;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
        leading: CircleAvatar(
          backgroundColor: navy.withOpacity(0.05),
          child: Icon(Icons.person_outline, color: navy),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
            fontFamily: 'Tajawal',
          ),
        ),
        subtitle: Text(
          info,
          style: TextStyle(fontSize: 12.sp, fontFamily: 'Tajawal'),
        ),
        trailing: needsAction
            ? ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  'retry'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontFamily: 'Tajawal',
                  ),
                ),
              )
            : Icon(
                Icons.check_circle_rounded,
                color: Colors.green.shade400,
                size: 24.sp,
              ),
      ),
    );
  }

  //  BottomNavigationBar مع التنقل
  Widget _buildBottomNav(Color navy, Color gold, String uid, String role) {
    final isArabic = context.locale.languageCode == 'ar';
    
    return BottomNavigationBar(
      selectedItemColor: gold,
      unselectedItemColor: navy.withOpacity(0.4),
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      selectedLabelStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 11),
      unselectedLabelStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 11),
      onTap: (index) {
        switch (index) {
          case 0:
            // الرئيسية (هو بالفعل عليها)
            break;
          case 1:
            // التنبيهات
            context.push(Routes.notification);
            break;
          case 2:
            // الطلبات
            context.push('/judge/orders-list');
            break;
          case 3:
            // الإعدادات
            context.push(Routes.settings, extra: {
              'uid': uid,
              'role': role,
            });
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.grid_view_rounded),
          label: 'dashboardJudge.tooltips.profile'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.notifications_active_outlined),
          label: isArabic ? 'التنبيهات' : 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.assignment_outlined),
          label: 'orders.title'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings_outlined),
          label: 'dashboardJudge.tooltips.logout'.tr(),
        ),
      ],
    );
  }
}