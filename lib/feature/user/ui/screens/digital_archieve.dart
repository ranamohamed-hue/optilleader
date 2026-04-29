import 'package:flutter/material.dart';

class DigitalArchivePage extends StatelessWidget {
  const DigitalArchivePage({super.key});

  @override
  Widget build(BuildContext context) {
    // --- سحب إعدادات الثيم لضمان التناسق ---
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        // استخدام لون الخلفية من الثيم (البيج الملكي)
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          elevation: 0,
          toolbarHeight: 80,
          automaticallyImplyLeading: false, // تحكم يدوي بالأزرار
          title: Row(
            children: [
              // 2. صورة البروفيل مع الإطار الذهبي
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
                'Digital Archive',
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 15),
              // 1. زر العودة للخلف (يسار)
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
            indicatorColor: colorScheme.secondary,
            indicatorWeight: 3,
            labelColor: colorScheme.secondary,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: "Research"),
              Tab(text: "Conferences"),
              Tab(text: "Others"),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // شريط البحث والفرز (مربوط بالألوان الكحلية من الثيم)
              Row(
                children: [
                  Icon(Icons.sort_rounded, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  Text(
                    "Sort by Date",
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.search, color: colorScheme.primary),
                ],
              ),
              const SizedBox(height: 20),

              // شبكة المجلدات
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.9,
                  children: [
                    _buildFolderCard(
                      context,
                      "Academic Certificates",
                      "3 weekly files",
                      Colors.teal.shade300,
                      3,
                    ),
                    _buildFolderCard(
                      context,
                      "Identification (ID)",
                      "4 weekly files",
                      Colors.amber.shade400,
                      4,
                    ),
                    _buildFolderCard(
                      context,
                      "Admin Decisions",
                      "5 promotion files",
                      Colors.blue.shade300,
                      5,
                    ),
                    _buildFolderCard(
                      context,
                      "Misc Documents",
                      "3 new alerts",
                      Colors.purple.shade300,
                      3,
                      badgeCount: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // زر الإضافة العائم في المنتصف
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: colorScheme.secondary,
          elevation: 4,
          child: Icon(Icons.add, size: 30, color: colorScheme.primary),
        ),

      ),
    );
  }

  // --- بناء كارت المجلد ---
  Widget _buildFolderCard(
    BuildContext context,
    String title,
    String subtitle,
    Color folderColor,
    int filesCount, {
    int badgeCount = 0,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.primary.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Icon(
                    Icons.folder_rounded,
                    size: 70,
                    color: folderColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "$filesCount",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // إشعار التنبيه الأحمر (Badge)
          if (badgeCount > 0)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "$badgeCount",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }


}
