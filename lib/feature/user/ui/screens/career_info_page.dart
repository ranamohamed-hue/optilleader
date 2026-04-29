import 'package:flutter/material.dart';

class CareerInfoPage extends StatelessWidget {
  const CareerInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // --- استخدام إعدادات الثيم الموحدة ---
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        toolbarHeight: 85,
        automaticallyImplyLeading: false, // تحكم يدوي بالهيدر
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
                radius: 22,
                backgroundColor: colorScheme.secondary.withOpacity(0.2),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),

            const SizedBox(width: 12),

            // 3. نصوص العنوان (الاسم والصفحة)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Career Information',
                  style: textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Dr. Mohamed Adel',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          
            const Spacer(),

            // زر التعديل (أيقونة ذهبية بستايل ملكي)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colorScheme.secondary.withOpacity(0.5),
                ),
              ),
              child: Icon(
                Icons.edit_note_rounded,
                color: colorScheme.secondary,
                size: 22,
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(color: colorScheme.secondary, height: 2),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // قسم المؤهلات العلمية
            _buildSectionHeader(
              context,
              Icons.school_outlined,
              'Academic Credentials',
            ),
            _buildCredentialCard(
              context,
              'Degree: Ph.D.',
              'Specialization: Computer Engineering',
              'Institution: Cairo University',
              'Date: 15/06/2015',
            ),
            _buildCredentialCard(
              context,
              'Degree: M.Sc.',
              'Specialization: Software Engineering',
              'Institution: Cairo University',
              'Date: 02/09/2010',
            ),
            _buildCredentialCard(
              context,
              'Degree: B.Sc.',
              'Specialization: Computer Science',
              'Institution: Cairo University',
              'Date: 10/07/2007',
              isLast: true,
            ),

            const SizedBox(height: 25),

            // قسم المسار الوظيفي
            _buildSectionHeader(
              context,
              Icons.history_edu_rounded,
              'Career Path',
            ),
            _buildCareerPathCard(context),

            const SizedBox(height: 25),

            // قسم بيانات العمل الحالية
            _buildSectionHeader(
              context,
              Icons.badge_outlined,
              'Current Employment',
            ),
            _buildCurrentInfoCard(context),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- شريط عنوان الأقسام ---
  Widget _buildSectionHeader(
    BuildContext context,
    IconData icon,
    String title,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
        border: Border.all(color: colorScheme.secondary.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.secondary, size: 22),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // --- كارت المؤهلات ---
  Widget _buildCredentialCard(
    BuildContext context,
    String degree,
    String spec,
    String inst,
    String date, {
    bool isLast = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(15))
            : BorderRadius.zero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: colorScheme.secondary, size: 16),
              const SizedBox(width: 8),
              Text(
                degree,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spec,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                Text(
                  inst,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                Text(
                  date,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- كارت المسار الوظيفي ---
  Widget _buildCareerPathCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
        border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current: Senior Lecturer since 28/04/2018',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Experience: 6 Years',
            style: TextStyle(
              color: colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: colorScheme.primary.withOpacity(0.1)),
          ),
          const Text(
            'Previous Positions:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 5),
          _buildHistoryItem(context, 'Lecturer', '01/03/2011 – 31/08/2015'),
          _buildHistoryItem(
            context,
            'Teaching Assistant',
            '15/07/2007 – 28/02/2011',
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, String title, String period) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.arrow_right, color: colorScheme.secondary),
          Text(
            '$title: ',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          Text(
            period,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // --- كارت معلومات العمل الحالية ---
  Widget _buildCurrentInfoCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
        border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            context,
            Icons.account_balance_rounded,
            'Dept:',
            'Faculty of Engineering, Computer Engineering',
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            context,
            Icons.assignment_ind_rounded,
            'Type:',
            'Permanent Employment',
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            context,
            Icons.calendar_today_rounded,
            'Hire Date:',
            '15/07/2007',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colorScheme.primary, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
