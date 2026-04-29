//userSearchScreen
import 'package:flutter/material.dart';

class UserSearchScreen extends StatelessWidget {
  const UserSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // سحب الألوان من الثيم الموحد لسهولة التعديل
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // يستخدم scaffoldBackgroundColor من الثيم
      appBar: AppBar(
        title: const Text('المستخدمون المسجلون'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        // خط التحديد الذهبي أسفل الـ AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(color: colorScheme.secondary, height: 2.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- شريط البحث ---
            // سيسحب الستايل تلقائياً من inputDecorationTheme في AppTheme
            TextField(
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                hintText: 'ابحث عن اسم، بريد، أو رقم وظيفي',
                prefixIcon: Icon(Icons.search),
              ),
            ),

            const SizedBox(height: 30),

            // --- نتيجة البحث (خدمات الموظف) ---
            _buildSectionHeader(context, 'خدمات الموظف'),

            Card(
              // الـ Card سيسحب ستايله من cardTheme
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // السطر العلوي: الصورة والمعلومات الأساسية
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'د. أحمد إبراهيم كمال',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'كلية الهندسة',
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              'الهندسة المدنية',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(width: 15),
                        // إطار الصورة باللون الذهبي (Secondary)
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: colorScheme.secondary, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: colorScheme.surfaceVariant,
                            child: Icon(Icons.person, color: colorScheme.primary, size: 40),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 25),

                    // السطر السفلي: البريد الإلكتروني
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'ahmed.kamal@university.edu.sa',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.email_outlined, color: colorScheme.secondary, size: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ودجت لعنوان القسم مرتبطة بالثيم
  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.label_important_outline, color: theme.colorScheme.secondary, size: 22),
        ],
      ),
    );
  }
}