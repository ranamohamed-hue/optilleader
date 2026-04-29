import 'package:flutter/material.dart';

class judgeSettingsScreen extends StatelessWidget {
  const judgeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // الربط المباشر بملفات الثيم اللي عملناها
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // الألوان اللي ضفناها للثيم عشان يكمل (البيج والذهبي الملكي)
    final scaffoldColor = theme.scaffoldBackgroundColor; // البيج الأساسي
    final navyColor = colorScheme.primary; // الكحلي
    final goldColor = colorScheme.secondary; // الذهبي

    return Scaffold(
      backgroundColor: scaffoldColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 1. الهيدر: مربوط بالـ primary (الكحلي)
            _buildHeader(context, navyColor, goldColor),

            const SizedBox(height: 40),

            // 2. قسم البيانات الشخصية
            _buildSectionHeader(navyColor, 'Personal Data', 'تعديل البيانات'),

            _buildInputField(
              context,
              goldColor,
              'DISPLAY NAME',
              'الاسم الظاهر',
              'Dr. Amina Mansour',
            ),
            _buildInputField(
              context,
              goldColor,
              'UNIVERSITY EMAIL',
              'البريد الإلكتروني',
              'amina.mansour@university.edu',
            ),
            _buildInputField(
              context,
              goldColor,
              'EMPLOYEE ID',
              'رقم الموظف',
              '1234567',
            ),
            _buildInputField(
              context,
              goldColor,
              'DEPARTMENT',
              'القسم',
              'Computer Science',
            ),

            const SizedBox(height: 20),

            // زر الحفظ: مربوط بالثيم الموحد
            _buildSaveButton(navyColor),

            const SizedBox(height: 30),

            // 3. قسم التفضيلات
            _buildSectionHeader(navyColor, 'PREFERENCES', 'التفضيلات'),

            _buildPreferenceLabel('LANGUAGE', 'اللغة'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  _buildSelectableBox(
                    context,
                    'العربية',
                    '🇸🇦',
                    false,
                    navyColor,
                    goldColor,
                  ),
                  const SizedBox(width: 12),
                  _buildSelectableBox(
                    context,
                    'ENGLISH',
                    '🇬🇧',
                    true,
                    navyColor,
                    goldColor,
                  ),
                ],
              ),
            ),

            _buildPreferenceLabel('APP THEME', 'الإضاءة'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  _buildSelectableBox(
                    context,
                    'Light Mode',
                    '☀️',
                    true,
                    navyColor,
                    goldColor,
                  ),
                  const SizedBox(width: 12),
                  _buildSelectableBox(
                    context,
                    'Dark Mode',
                    '🌙',
                    false,
                    navyColor,
                    goldColor,
                  ),
                ],
              ),
            ),

            // تايتل الإشعارات مربوط بالذهبي
            _buildNotificationTile(navyColor, goldColor),

            const SizedBox(height: 30),

            // 4. أزرار الخطر والخروج
            _buildDangerButton('DELETE ACCOUNT', 'حذف الحساب'),
            const SizedBox(height: 25),
            _buildLogoutButton(navyColor),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- ميثودات بناء العناصر المربوطة بالثيم ---

  Widget _buildHeader(BuildContext context, Color primary, Color secondary) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, primary.withOpacity(0.85)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Admin Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'University System Panel',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: -45,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 55,
              backgroundColor: secondary.withOpacity(0.2),
              child: Icon(Icons.person_rounded, size: 60, color: primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(
    BuildContext context,
    Color gold,
    String en,
    String ar,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                en,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ar,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: gold.withOpacity(0.1)),
            ),
            child: TextField(
              textAlign: TextAlign.right,
              controller: TextEditingController(text: value),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.edit_note, color: gold),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableBox(
    BuildContext context,
    String title,
    String icon,
    bool isSelected,
    Color navy,
    Color gold,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? navy : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isSelected ? gold : Colors.grey.shade200),
          boxShadow: isSelected
              ? [BoxShadow(color: navy.withOpacity(0.2), blurRadius: 8)]
              : [],
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : navy,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(Color primary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
        ),
        child: const Text(
          'SAVE CHANGES / حفظ التغييرات',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildNotificationTile(Color navy, Color gold) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: gold.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Switch(value: true, onChanged: (v) {}, activeColor: navy),
        trailing: Icon(Icons.notifications_active, color: gold),
        title: Text(
          'الإشعارات',
          textAlign: TextAlign.right,
          style: TextStyle(fontWeight: FontWeight.bold, color: navy),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(Color navy, String en, String ar) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            en,
            style: TextStyle(
              color: navy,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          Text(
            ar,
            style: TextStyle(
              color: navy,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceLabel(String en, String ar) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(en, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(ar, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDangerButton(String en, String ar) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.redAccent, width: 1.5),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          '$en / $ar',
          style: const TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(Color navy) {
    return Column(
      children: [
        Icon(Icons.power_settings_new, color: navy, size: 30),
        Text(
          'LOGOUT',
          style: TextStyle(color: navy, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
