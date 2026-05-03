import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:optialeader/core/theming/app_color.dart';

class DataEntryDashboard extends StatelessWidget {
  const DataEntryDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // سحب الثيم الحالي (Light/Dark)
    final theme = Theme.of(context);

    // بيانات المستخدم (رنا)
    const String userName = "رنا محمد";
    const String profileImageUrl =
        "https://res.cloudinary.com/dcwodhs3c/image/upload/Screenshot_2026-04-28_at_20-39-55_pngtree-helpline-female-receptionist-happy-photo-image_6684496.jpg_%D8%B5%D9%88%D8%B1%D8%A9_JPEG_360_550_%D8%A8%D9%83%D8%B3%D9%84_mii82j.png";

    return Scaffold(
      // استخدام اللون الخلفي من الثيم بدلاً من اللون اليدوي
      backgroundColor: theme.scaffoldBackgroundColor,
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
                backgroundColor: Colors.white,
                backgroundImage: const NetworkImage(profileImageUrl),
              ),
            ),
            SizedBox(width: 15.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "مرحباً بكِ،",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                Text(
                  userName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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
            // --- قسم الإحصائيات ---
            Text(
              "نظرة عامة على النظام",
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.navyDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15.h),
            Row(
              children: [
                _buildStatCard(
                  context,
                  "الدكاترة",
                  "25",
                  Icons.school,
                  Colors.blue,
                ),
                _buildStatCard(
                  context,
                  "المحكمين",
                  "12",
                  Icons.gavel,
                  Colors.orange,
                ),
                _buildStatCard(
                  context,
                  "الإداريين",
                  "8",
                  Icons.admin_panel_settings,
                  Colors.green,
                ),
              ],
            ),

            SizedBox(height: 40.h),

            // --- قسم الأزرار ---
            Text(
              "إدارة البيانات الجديدة",
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.navyDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15.h),

            // ربط الأزرار بالصفحات اللي عملناها
            _buildActionCard(
              context,
              "إضافة عضو هيئة تدريس",
              Icons.person_add_alt_1,
              AppColors.navyDark,
            ),
            _buildActionCard(
              context,
              "إضافة مسؤول إداري",
              Icons.manage_accounts,
              const Color(0xFF1A1A40),
            ),
            _buildActionCard(
              context,
              "إضافة محكم علمي",
              Icons.verified_user,
              const Color(0xFF2E2E5D),
            ),
          ],
        ),
      ),
    );
  }

  // Widget كرت الإحصائيات مربوط بالـ CardTheme بتاعك
  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        // الكارد هنا هيسحب الـ borderRadius: 25 من ملف الثيم بتاعك أوتوماتيك
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        child: Padding(
          padding: EdgeInsets.all(15.w),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24.sp),
              SizedBox(height: 8.h),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget أزرار الإضافة بشكل كروت عريضة
  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color bgColor,
  ) {
    return GestureDetector(
      onTap: () {
        // هنا هنضيف الـ Navigation لاحقاً
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 15.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(
            15.r,
          ), // متناسق مع تصميم الـ Action Cards
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.darkGold, size: 30.sp),
            SizedBox(width: 20.w),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white24,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
