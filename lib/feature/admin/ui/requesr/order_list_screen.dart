import 'package:flutter/material.dart';

// [ملاحظة]: شلنا الـ main من هنا عشان الملف ده هيندرج تحت الـ AppRouter بتاعنا

class OrdersListScreen extends StatelessWidget {
  const OrdersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // جلب ألوان الثيم الحالي
    final theme = Theme.of(context);
    final primaryNavy = theme.primaryColor; // الكحلي الملكي من الثيم
    final goldAccent = theme.colorScheme.secondary; // الذهبي من الثيم
    final bgLight = theme.scaffoldBackgroundColor; // الخلفية الكريمي أو الداكنة

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgLight,
        appBar: AppBar(
          backgroundColor: primaryNavy,
          elevation: 10,
          shadowColor: Colors.black.withOpacity(0.3),
          title: Text(
            'إدارة الطلبات',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: const Icon(Icons.menu, color: Colors.white),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Container(color: goldAccent, height: 4.0),
          ),
        ),
        body: Column(
          children: [
            // --- شريط البحث العلوي بتصميم مودرن ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor, // يتبع الثيم (أبيض أو رمادي غامق)
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                textAlign: TextAlign.right,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'بحث عن طلب برقم الهوية أو الاسم...',
                  hintStyle: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: primaryNavy),
                  filled: true,
                  fillColor: bgLight.withOpacity(0.4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // --- قائمة الطلبات ---
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(15),
                children: [
                  _buildOrderItem(
                    context,
                    'سارة محمد عبد الرحمن',
                    'جديد',
                    Colors.blue,
                    '2024/03/15',
                  ),
                  _buildOrderItem(
                    context,
                    'أحمد علي محمد',
                    'قيد التحكيم',
                    Colors.orange,
                    '2024/03/10',
                  ),
                  _buildOrderItem(
                    context,
                    'منى محمود حسن',
                    'معتمد',
                    Colors.green,
                    '2024/03/05',
                  ),
                  _buildOrderItem(
                    context,
                    'د. رامي عبد العزيز',
                    'جديد',
                    Colors.blue,
                    '2024/03/01',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(
    BuildContext context,
    String name,
    String status,
    Color statusColor,
    String date,
  ) {
    final theme = Theme.of(context);
    final goldAccent = theme.colorScheme.secondary;
    final primaryNavy = theme.primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: goldAccent.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryNavy.withOpacity(0.05),
            border: Border.all(color: goldAccent.withOpacity(0.5)),
          ),
          child: Icon(Icons.description_outlined, color: primaryNavy),
        ),
        title: Text(
          name,
          style: theme.textTheme.titleMedium?.copyWith(
            color: primaryNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(date, style: theme.textTheme.bodySmall),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withOpacity(0.5)),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FullEmployeeReportScreen(),
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// الشاشة الثانية: مراجعة ملف الموظف والاعتماد الإداري
// =============================================================================
class FullEmployeeReportScreen extends StatelessWidget {
  const FullEmployeeReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryNavy = theme.primaryColor;
    final goldAccent = theme.colorScheme.secondary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: primaryNavy,
          elevation: 0,
          title: Text(
            'مراجعة الملف والاعتماد',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(3.0),
            child: Container(color: goldAccent, height: 3.0),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEmployeeHeader(context),
              const SizedBox(height: 10),
              _buildSectionTitle(context, "الموقف الوظيفي والترقيات"),
              _buildInfoRow(context, "تاريخ التعيين:", "15/09/2014"),
              _buildInfoRow(context, "آخر ترقية:", "01/01/2020"),
              _buildInfoRow(context, "الدرجة الحالية:", "أستاذ مشارك"),
              _buildStatusCheck(context, "استيفاء المدة القانونية للترقية"),
              _buildPromotionTable(context),
              _buildSectionTitle(context, "السجل الانضباطي"),
              _buildInfoRow(context, "عدد الجزاءات (آخر 5 سنوات):", "0"),
              _buildInfoRow(context, "تنبيهات إدارية:", "لا يوجد"),
              _buildStatusCheck(context, "الموقف الانضباطي سليم"),
              _buildSectionTitle(context, "العبء التدريسي والمقررات"),
              _buildCourseTable(context),
              _buildStatusCheck(context, "تمت مراجعة العبء المسحوب من النظام"),
              _buildSectionTitle(context, "المرفقات الإدارية"),
              _buildAttachmentItem(context, "شهادة التخرج الموثقة (PhD).pdf"),
              _buildAttachmentItem(
                context,
                "قرار التعيين على الدرجة الحالية.pdf",
              ),
              _buildStatusCheck(context, "تمت مراجعة جميع المرفقات وتطابقها"),
              const SizedBox(height: 30),
              _buildActionSection(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- دوال البناء (Widgets) مربوطة بالثيم ---

  Widget _buildEmployeeHeader(BuildContext context) {
    final theme = Theme.of(context);
    final goldAccent = theme.colorScheme.secondary;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: goldAccent.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: goldAccent, width: 2),
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: theme.primaryColor,
              child: Icon(Icons.person, color: goldAccent, size: 35),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'د. رامي عبد العزيز',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'الرقم الوظيفي: 44201 | قسم الحاسب',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20, bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          right: BorderSide(color: theme.colorScheme.secondary, width: 4),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          _buildActiveSwitch(),
        ],
      ),
    );
  }

  Widget _buildPromotionTable(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Table(
        border: TableBorder.all(color: theme.dividerColor.withOpacity(0.5)),
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.03),
            ),
            children: [
              _p(context, "تاريخ الترقية", isHeader: true),
              _p(context, "المسمى السابق", isHeader: true),
              _p(context, "المسمى الجديد", isHeader: true),
            ],
          ),
          TableRow(
            children: [
              _p(context, "01/01/2020"),
              _p(context, "أستاذ مساعد"),
              _p(context, "أستاذ مشارك"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseTable(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Table(
        columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1)},
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.03),
            ),
            children: [
              _p(context, "اسم المقرر (Code)", isHeader: true),
              _p(context, "عدد الساعات", isHeader: true),
            ],
          ),
          TableRow(
            children: [_p(context, "خوارزميات (CS301)"), _p(context, "4")],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCheck(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.secondary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentItem(BuildContext context, String fileName) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
        title: Text(
          fileName,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          Icons.verified_user,
          color: theme.colorScheme.secondary,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildActionSection(BuildContext context) {
    final theme = Theme.of(context);
    final goldAccent = theme.colorScheme.secondary;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: goldAccent.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            dropdownColor: theme.cardColor,
            decoration: InputDecoration(
              labelText: "اختيار المحكم الفني المختص للملف",
              labelStyle: TextStyle(
                color: theme.primaryColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              filled: true,
              fillColor: theme.scaffoldBackgroundColor.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: goldAccent),
              ),
            ),
            items: ["أ.د. محمد علي", "أ.د. سارة محمود"]
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, style: theme.textTheme.bodyMedium),
                  ),
                )
                .toList(),
            onChanged: (v) {},
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: goldAccent, width: 1),
            ),
            onPressed: () {},
            icon: Icon(Icons.verified, color: goldAccent),
            label: const Text(
              "اعتماد الملف وتحويله للمحكم",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _p(BuildContext context, String t, {bool isHeader = false}) => Padding(
    padding: const EdgeInsets.all(10),
    child: Text(
      t,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: isHeader ? 11 : 12,
        fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        color: isHeader ? Theme.of(context).primaryColor : null,
      ),
    ),
  );

  Widget _buildActiveSwitch() {
    return Container(
      width: 40,
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Align(
        alignment: Alignment.centerLeft,
        child: CircleAvatar(radius: 7, backgroundColor: Colors.white),
      ),
    );
  }
}
