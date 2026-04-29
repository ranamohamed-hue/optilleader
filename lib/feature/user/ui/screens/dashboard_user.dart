import 'package:flutter/material.dart';

class DashboardUserPage extends StatelessWidget {
  const DashboardUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    // جلب الألوان والستايل من الثيم العام للمشروع (الهوية الملكية)
    final theme = Theme.of(context);
    final primaryNavy = theme.colorScheme.primary; 
    final goldAccent = theme.colorScheme.secondary;
    final scaffoldBg = theme.scaffoldBackgroundColor;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: scaffoldBg,
      appBar: AppBar(
  backgroundColor: primaryNavy,
  elevation: 10,
  toolbarHeight: 85,
  automaticallyImplyLeading: false, // نلغي الـ leading الافتراضي عشان عملناه يدوي
  title: Row(
    children: [
      // بروفايل المستخدم
      Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: goldAccent, width: 1.5),
        ),
        child: CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white.withOpacity(0.1),
          child: Icon(Icons.person, color: goldAccent, size: 28),
        ),
      ),
      const SizedBox(width: 12),
      // النصوص
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('مرحباً بك،', style: TextStyle(color: Colors.white70, fontSize: 11)),
          Text('د. أحمد إبراهيم', 
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
      const Spacer(), // بياخد كل المساحة الفاضية ويخلي زر العودة في الآخر تماماً
      // زر العودة
      IconButton(
        icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20), // السهم لليسار في RTL يعني عودة
        onPressed: () => Navigator.of(context).pop(),
      ),
    ],
  ),
  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(4),
    child: Container(color: goldAccent, height: 4),
  ),
),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // شبكة الإحصائيات مربوطة بالثيم
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.1,
                children: [
                  _buildStatCard('الإنجازات', Icons.emoji_events_outlined, goldAccent, '8 أبحاث منشورة\n240+ محاضرة', primaryNavy),
                  _buildStatCard('بيانات أكاديمية', Icons.school_outlined, goldAccent, 'أستاذ مشارك\nقسم الهندسة', primaryNavy),
                  _buildStatusCard('حالة الطلبات', '3', 'قيد الانتظار', Colors.red.shade50, Colors.red.shade900),
                  _buildProgressCard('المسار الوظيفي', 0.75, primaryNavy, goldAccent),
                ],
              ),

              const SizedBox(height: 30),

              // قسم الفرص المتاحة (التصميم الموحد مع الأرشيف)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 4, height: 18, decoration: BoxDecoration(color: goldAccent, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 8),
                      Text('أحدث الفرص', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: primaryNavy)),
                    ],
                  ),
                  TextButton(
                    onPressed: () {}, 
                    child: Text('عرض الكل', style: TextStyle(color: goldAccent, fontWeight: FontWeight.bold))
                  ),
                ],
              ),
              
              const SizedBox(height: 10),
              _buildOpportunityItem(
                'طلب ترقية الربيع',
                'يمكنك الآن التقديم على ترقيات أعضاء هيئة التدريس.',
                Icons.campaign_outlined,
                primaryNavy.withOpacity(0.05),
                primaryNavy,
                goldAccent,
              ),
              const SizedBox(height: 12),
              _buildOpportunityItem(
                'تمويل بحثي متاح',
                'تم فتح باب التقديم للحصول على تمويل للمشاريع البحثية الجديدة.',
                Icons.lightbulb_outline,
                primaryNavy.withOpacity(0.05),
                primaryNavy,
                goldAccent,
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(primaryNavy, goldAccent),
      ),
    );
  }

  // --- Helper Widgets مربوطة كلياً بالثيم ---

  Widget _buildStatCard(String title, IconData icon, Color gold, String content, Color navy) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15), 
        border: Border.all(color: gold.withOpacity(0.3), width: 1.2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: gold, size: 18), const SizedBox(width: 5), Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: navy, fontSize: 13))]),
          const Spacer(),
          Text(content, style: TextStyle(color: Colors.grey.shade700, fontSize: 11, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, String count, String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bgColor, 
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 12)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(count, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                  Text(label, style: TextStyle(color: textColor, fontSize: 10)),
                ],
              ),
              Icon(Icons.notifications_active_outlined, color: textColor.withOpacity(0.5), size: 24),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildProgressCard(String title, double progress, Color navy, Color gold) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: navy.withOpacity(0.1), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: navy, fontSize: 13)),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress, 
              backgroundColor: navy.withOpacity(0.05), 
              color: gold, 
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text('${(progress * 100).toInt()}% اكتمل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: navy)),
        ],
      ),
    );
  }

  Widget _buildOpportunityItem(String title, String subtitle, IconData icon, Color iconBg, Color navy, Color gold) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: gold.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: navy),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: navy)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: gold),
        ],
      ),
    );
  }

  Widget _buildBottomNav(Color navy, Color gold) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: gold,
      unselectedItemColor: Colors.grey,
      currentIndex: 4, 
      backgroundColor: Colors.white,
      elevation: 20,
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'الإعدادات'),
        const BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'التنبيهات'),
     
        const BottomNavigationBarItem(icon: Icon(Icons.folder_open_outlined), label: 'الملفات'),
        const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'الرئيسية'),
      ],
    );
  }
}