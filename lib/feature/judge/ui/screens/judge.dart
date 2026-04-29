import 'package:flutter/material.dart';

class MohakemDashboardHome extends StatelessWidget {
  const MohakemDashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    // استدعاء الألوان من الثيم مباشرة
    final theme = Theme.of(context);
    final colorPrimary = theme.colorScheme.primary;
    final colorGold = theme.colorScheme.secondary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            // الجزء العلوي مرتبط بلون الثيم الأساسي (النيفي)
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: colorPrimary,
                
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // الهيدر
                  _buildHeader(colorGold),

                  // الخط الذهبي (باستخدام لون الثيم)
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
                            'ملخص العمليات اليومية',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: colorPrimary,
                            ),
                          ),
                          const SizedBox(height: 15),

                          // كروت الإحصائيات مربوطة بالثيم
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  'طلبات معلقة',
                                  '24',
                                  Icons.pending_actions,
                                  true,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: _buildStatCard(
                                  context,
                                  'مراجعات ناجحة',
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
                            'الإعلانات النشطة',
                          ),
                          const SizedBox(height: 12),
                          _buildAnnouncementCard(
                            context,
                            'الترقية السنوية 2024',
                            'آخر موعد: 30 مايو',
                            '14 طلب جديد',
                          ),

                          const SizedBox(height: 30),
                          _buildSectionTitle(
                            colorGold,
                            colorPrimary,
                            'أحدث المتقدمين',
                          ),
                          const SizedBox(height: 12),

                          // استخدام الـ Card اللي استقرينا عليه في صفحات الأرشيف
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
      ),
    );
  }

  // --- Widgets مربوطة بالثيم ---

  Widget _buildHeader(Color gold) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white12,
                child: Icon(Icons.person, color: gold),
              ),
              const SizedBox(width: 15),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المهندسة رنا',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'إدارة النظام الإداري',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildGoldLine(Color gold) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 45),
      height: 2,
      decoration: BoxDecoration(
        color: gold,
        boxShadow: [BoxShadow(color: gold.withOpacity(0.4), blurRadius: 4)],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String count,
    IconData icon,
    bool isPrimary,
  ) {
    final gold = Theme.of(context).colorScheme.secondary;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPrimary ? gold : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: isPrimary ? Colors.white : gold, size: 30),
          const SizedBox(height: 15),
          Text(
            count,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: isPrimary ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: isPrimary ? Colors.white70 : Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(Color gold, Color navy, String title) {
    return Row(
      children: [
        Container(width: 4, height: 18, color: gold),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: navy,
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementCard(
    BuildContext context,
    String title,
    String date,
    String stats,
  ) {
    final navy = Theme.of(context).colorScheme.primary;
    final gold = Theme.of(context).colorScheme.secondary;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: gold.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Icon(Icons.campaign, color: gold, size: 35),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: navy),
        ),
        subtitle: Text(date),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: navy,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            stats,
            style: TextStyle(
              color: gold,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildApplicantItem(
    BuildContext context,
    String name,
    String college,
    bool action,
  ) {
    final navy = Theme.of(context).colorScheme.primary;
    final gold = Theme.of(context).colorScheme.secondary;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[100],
          child: Icon(Icons.person, color: navy),
        ),
        title: Text(
          name,
          style: TextStyle(fontWeight: FontWeight.bold, color: navy),
        ),
        subtitle: Text(college),
        trailing: action
            ? ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: Colors.white,
                ),
                child: const Text('مراجعة'),
              )
            : Icon(Icons.check_circle, color: Colors.green[700]),
      ),
    );
  }

  Widget _buildBottomNav(Color navy, Color gold) {
    return BottomNavigationBar(
      selectedItemColor: gold,
      unselectedItemColor: navy.withOpacity(0.4),
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'الرئيسية'),
                BottomNavigationBarItem(icon: Icon(Icons.announcement), label: 'الاشعارات'),

        BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'الطلبات'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
      ],
    );
  }
}
