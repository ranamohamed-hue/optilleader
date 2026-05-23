import 'dart:io'; // ✅ [مهم] لإدارة كائن File
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart'; // ✅ لاختيار الصور
import 'package:cached_network_image/cached_network_image.dart'; // ✅ لعرض الصور بكفاءة
import 'package:optialeader/feature/database_admin/logic/judge_data/judge_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/judge_data/judge_data_state.dart';

class MohakemDashboardHome extends StatelessWidget {
  const MohakemDashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorPrimary = theme.colorScheme.primary;
    final colorGold = theme.colorScheme.secondary;

    return BlocBuilder<JudgeDataCubit, JudgeDataState>(
      builder: (context, state) {
        // 1. حالة التحميل العامة
        if (state is JudgeLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. حالة الخطأ
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

        // 3. الحالة الناجحة
        if (state is JudgeLoaded) {
          final judge = state.judge!;
          final isArabic = context.locale.languageCode == 'ar';

          final displayName = isArabic
              ? (judge.nameAr.isNotEmpty ? judge.nameAr : "محكم")
              : (judge.nameEn.isNotEmpty ? judge.nameEn : "Judge");

          final displayJob = isArabic
              ? (judge.jopAr.isNotEmpty ? judge.jopAr : "محكم معتمد")
              : (judge.jopEn.isNotEmpty ? judge.jopEn : "Certified Judge");

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorPrimary,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        _buildAppBar(context),
                        _buildHeader(
                          context,
                          colorGold,
                          displayName,
                          displayJob,
                          judge.profileImage,
                          judge.uid, // ✅ تمرير الـ uid لدالة الهيدر
                        ),
                        SizedBox(height: 15.h),
                        _buildGoldLine(colorGold),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 25.h),
                        Text(
                          'dashboard.system_overview'.tr(),
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
                                'dashboard.cards.under_review'.tr(),
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
                          'سعود صالح القحطاني',
                          displayJob,
                          true,
                        ),
                        _buildApplicantItem(
                          context,
                          'نورة عبد الرحمن',
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
            bottomNavigationBar: _buildBottomNav(colorPrimary, colorGold),
          );
        }

        return const Scaffold(body: SizedBox.shrink());
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 20.sp,
              color: Colors.white,
            ),
            onPressed: () => context.canPop() ? context.pop() : null,
          ),
        ],
      ),
    );
  }

  // ✅ [تعديل] إضافة uid كـ Parameter لاستخدامه في رفع الصورة
  Widget _buildHeader(
    BuildContext context,
    Color gold,
    String name,
    String job,
    String? imageUrl,
    String uid, 
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                // ✅ [تعديل] تحويل الصورة إلى زر قابل للنقر لرفع صورة جديدة
                GestureDetector(
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                      requestFullMetadata: false,
                    );

                    if (pickedFile != null && context.mounted) {
                      context.read<JudgeDataCubit>().updateJudgeProfileImage(
                            uid,
                            File(pickedFile.path),
                          );
                    }
                  },
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 26.r,
                        backgroundColor: Colors.white.withOpacity(0.15),
                        child: ClipOval(
                          child: (imageUrl != null && imageUrl.isNotEmpty)
                              ? CachedNetworkImage( // ✅ استخدام CachedNetworkImage بدلاً من NetworkImage
                                  imageUrl: imageUrl,
                                  width: 52.r,
                                  height: 52.r,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Icon(Icons.person, color: gold, size: 30.sp),
                                  errorWidget: (_, __, ___) => Icon(Icons.person, color: gold, size: 30.sp),
                                )
                              : Icon(Icons.person, color: gold, size: 30.sp),
                        ),
                      ),
                      // ✅ أيقونة الكاميرا الصغيرة فوق الصورة
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: BoxDecoration(
                            color: gold,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Icon(Icons.camera_alt, size: 12.r, color: Colors.white),
                        ),
                      ),
                      
                      // ✅ مؤشر تحميل يظهر فوق الصورة أثناء الرفع لـ Supabase والضغط
                      BlocBuilder<JudgeDataCubit, JudgeDataState>(
                        builder: (context, state) {
                          if (state is JudgeLoading) {
                            return Container(
                              width: 52.r,
                              height: 52.r,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: 20.r,
                                  height: 20.r,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.r),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'dashboard.welcome'.tr(args: [name]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        job,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11.sp,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white,
            size: 30,
          ),
        ],
      ),
    );
  }

  Widget _buildGoldLine(Color gold) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 45.w),
      height: 2.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gold.withOpacity(0.1), gold, gold.withOpacity(0.1)],
        ),
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

  Widget _buildBottomNav(Color navy, Color gold) {
    return BottomNavigationBar(
      selectedItemColor: gold,
      unselectedItemColor: navy.withOpacity(0.4),
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      selectedLabelStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 11),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Tajawal',
        fontSize: 11,
      ),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.grid_view_rounded),
          label: 'dashboard.tooltips.profile'.tr(),
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.notifications_active_outlined),
          label: 'التنبيهات',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.assignment_outlined),
          label: 'orders.title'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings_outlined),
          label: 'dashboard.tooltips.logout'.tr(),
        ),
      ],
    );
  }
}