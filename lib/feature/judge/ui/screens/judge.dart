import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/routing/routes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MohakemDashboardHome extends StatelessWidget {
  const MohakemDashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorPrimary = theme.colorScheme.primary;
    final colorGold = theme.colorScheme.secondary;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20.sp,
            color: Colors.white,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // الجزء العلوي (Navy Background)
          Container(
            height: 180.h, // استخدام screenutil للارتفاع
            decoration: BoxDecoration(
              color: colorPrimary,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // الهيدر (مع استخدام الترجمة والاسم الديناميكي)
                _buildHeader(context, colorGold),

                _buildGoldLine(colorGold),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 25),
                        Text(
                          'dashboard.system_overview'.tr(), // من ملف JSON
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: colorPrimary,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        const SizedBox(height: 15),

                        // كروت الإحصائيات
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                context,
                                'dashboard.cards.under_review'.tr(),
                                '24',
                                Icons.pending_actions,
                                true,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildStatCard(
                                context,
                                'orders.status_approved'.tr(),
                                '156',
                                Icons.verified,
                                false,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),
                        _buildSectionTitle(
                          colorGold,
                          colorPrimary,
                          'announcements.title'.tr(),
                        ),
                        const SizedBox(height: 12),
                        _buildAnnouncementCard(
                          context,
                          'الترقية السنوية 2024',
                          '30 مايو',
                          '14',
                        ),

                        const SizedBox(height: 30),
                        _buildSectionTitle(
                          colorGold,
                          colorPrimary,
                          'orders.report_title'.tr(),
                        ),
                        const SizedBox(height: 12),

                        _buildApplicantItem(
                          context,
                          'سعود صالح القحطاني',
                          'كلية علوم الحاسب',
                          true,
                        ),
                        _buildApplicantItem(
                          context,
                          'نورة عبد الرحمن',
                          'قسم الفيزياء التطبيقية',
                          false,
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(colorPrimary, colorGold),
    );
  }

  // --- Widgets المساعدة ---

  Widget _buildHeader(BuildContext context, Color gold) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white.withOpacity(0.15),
                child: Icon(Icons.person, color: gold, size: 30),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'dashboard.welcome'.tr(
                      args: ['رنا'],
                    ), // استخدام المتغير من الـ JSON
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  Text(
                    'dashboard.default_job'.tr(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ],
              ),
            ],
          ),
          Stack(
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 30,
              ),
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: gold,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black26, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoldLine(Color gold) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 45),
      height: 2.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gold.withOpacity(0.1), gold, gold.withOpacity(0.1)],
        ),
        boxShadow: [BoxShadow(color: gold.withOpacity(0.3), blurRadius: 6)],
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isGold ? gold : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: isGold ? null : Border.all(color: gold.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isGold
                  ? Colors.white.withOpacity(0.2)
                  : gold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isGold ? Colors.white : gold, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isGold ? Colors.white : navy,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: isGold ? Colors.white.withOpacity(0.9) : Colors.grey[600],
              fontWeight: FontWeight.w600,
              fontFamily: 'Tajawal',
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
          width: 5,
          height: 20,
          decoration: BoxDecoration(
            color: gold,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: navy,
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementCard(
    BuildContext context,
    String title,
    String date,
    String count,
  ) {
    final gold = Theme.of(context).colorScheme.secondary;
    final navy = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gold.withOpacity(0.15)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: gold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.campaign_rounded, color: gold, size: 28),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: navy,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          '${'announcement_details.deadline_label'.tr()}: $date',
          style: const TextStyle(fontSize: 11),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count,
              style: TextStyle(
                color: gold,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              'announcements.applicant_unit'.tr(),
              style: const TextStyle(fontSize: 9, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicantItem(
    BuildContext context,
    String name,
    String info,
    bool needsAction,
  ) {
    final gold = Theme.of(context).colorScheme.secondary;
    final navy = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: navy.withOpacity(0.05),
          child: Icon(Icons.person_outline, color: navy),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: navy,
            fontSize: 14,
          ),
        ),
        subtitle: Text(info, style: const TextStyle(fontSize: 12)),
        trailing: needsAction
            ? ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                ),
                child: Text(
                  'retry'.tr(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : Icon(
                Icons.check_circle_rounded,
                color: Colors.green.shade400,
                size: 28,
              ),
      ),
    );
  }

  Widget _buildBottomNav(Color navy, Color gold) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20),
        ],
      ),
      child: BottomNavigationBar(
        selectedItemColor: gold,
        unselectedItemColor: navy.withOpacity(0.4),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          fontFamily: 'Tajawal',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontFamily: 'Tajawal',
        ),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.grid_view_rounded),
            label: 'dashboard.tooltips.profile'.tr(),
          ), // استخدمت Profile كمثال
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
      ),
    );
  }
}
