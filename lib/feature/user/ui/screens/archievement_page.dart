import 'package:flutter/material.dart';

class AchievementsLogPage extends StatelessWidget {
  const AchievementsLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    // --- سحب إعدادات الثيم لضمان التناسق ---
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        // استخدام لون الخلفية من الثيم
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          elevation: 0,
          toolbarHeight: 80,
          automaticallyImplyLeading:
              false, // إلغاء الزر الافتراضي للتحكم اليدوي
          title: Row(
            children: [
            

              const SizedBox(width: 5),

              // 2. صورة البروفيل بإطار ذهبي
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.secondary, width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: colorScheme.secondary.withOpacity(0.2),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 3. عنوان الصفحة
              Text(
                'Achievements Log',
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              // أيقونة الكأس (ذهبية)
              Icon(Icons.emoji_events, color: colorScheme.secondary),
                // 1. زر العودة للخلف في أقصى اليسار
                SizedBox(width: 15,),
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
            
          ),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: colorScheme.secondary,
            indicatorWeight: 3,
            labelColor: colorScheme.secondary,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: "Research"),
              Tab(text: "Conferences"),
              Tab(text: "Activities"),
              Tab(text: "Courses"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAchievementsList(context),
            const Center(child: Text("Conferences Content")),
            const Center(child: Text("Other Activities")),
            const Center(child: Text("Courses List")),
          ],
        ),

        // الزر العائم (مرتبط بالثيم)
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: colorScheme.secondary,
          elevation: 4,
          child: Icon(Icons.add, size: 30, color: colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildAchievementsList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildAchievementCard(
          context,
          title: "Machine Learning for Network Security",
          date: "15 March 2024",
          status: "Accepted",
          statusColor: Colors.green.shade700,
          icon: Icons.check_circle_outline,
        ),
        _buildAchievementCard(
          context,
          title: "Blockchain Applications in IoT",
          date: "10 Dec 2023",
          status: "Under Review",
          statusColor: Colors.orange.shade800,
          icon: Icons.hourglass_empty_rounded,
        ),
        _buildAchievementCard(
          context,
          title: "Cloud Computing in Higher Education",
          date: "02 Aug 2023",
          status: "Rejected",
          statusColor: Colors.red.shade700,
          icon: Icons.cancel_outlined,
        ),
        const SizedBox(height: 25),

        // قسم المقترحات
        Row(
          children: [
            Icon(Icons.analytics_outlined, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              "Research Proposals",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        _buildSimpleCard(
          context,
          "Advanced Methodology in Crisis Management...",
        ),
        _buildSimpleCard(
          context,
          "Scientific Standards in Software Ranking...",
        ),
      ],
    );
  }

  Widget _buildAchievementCard(
    BuildContext context, {
    required String title,
    required String date,
    required String status,
    required Color statusColor,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    date,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: statusColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 14, color: statusColor),
                    const SizedBox(width: 5),
                    Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleCard(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: colorScheme.primary.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: colorScheme.secondary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.primary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
