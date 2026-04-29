import 'package:flutter/material.dart';

class EmployeeReviewScreen extends StatelessWidget {
  const EmployeeReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // سحب الثيم الموحد
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // الخلفية تقرأ من scaffoldBackgroundColor في الثيم
      appBar: AppBar(
        title: const Text('مراجعة ملف الموظف والاعتماد'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(color: colorScheme.secondary, height: 2.0),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 15),

            // 1. كارت بيانات الموظف الأساسية (يستخدم CardTheme)
            _buildEmployeeInfoCard(context),

            // 2. الموقف الوظيفي (يستخدم DataTableTheme من الثيم)
            _buildSection(
              context,
              title: 'الموقف الوظيفي والترقيات',
              isActive: true,
              child: _buildPromotionsTable(context),
            ),

            // 3. العبء التدريسي
            _buildSection(
              context,
              title: 'العبء التدريسي والمقررات',
              isActive: true,
              child: _buildTeachingLoadTable(context),
              footerText: 'تم مراجعة العبء والمقررات المسحوبة',
            ),

            // 4. المرفقات الإدارية
            _buildSection(
              context,
              title: 'المرفقات الإدارية',
              isActive: false,
              child: _buildAttachmentsList(context),
              footerText: 'تم مراجعة جميع المرفقات المسحوبة من النظام',
            ),

            // 5. اختيار المحكم المختص
            _buildJudgeSelection(context),

            // 6. زر الاعتماد النهائي (يستخدم ElevatedButtonTheme)
            _buildSubmitButton(context),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('د. أحمد منصور', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  _infoRow('15/05/1975', 'تاريخ الميلاد:'),
                  _infoRow('10/10/2000', 'تاريخ الالتحاق:'),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.secondary, width: 2),
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: theme.colorScheme.surface,
                child: Icon(Icons.person, size: 50, color: theme.colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String value, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required bool isActive, required Widget child, String? footerText}) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        children: [
          ListTile(
            trailing: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            leading: Switch(
              value: isActive,
              onChanged: (v) {},
              activeColor: Colors.green,
            ),
          ),
          child,
          if (footerText != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Text(footerText, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 11)),
            ),
        ],
      ),
    );
  }

  Widget _buildPromotionsTable(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Table(
        border: TableBorder.all(color: theme.colorScheme.secondary.withOpacity(0.2)),
        children: const [
          TableRow(children: [
            _TableCell('المسمى الجديد', isHeader: true),
            _TableCell('المسمى السابق', isHeader: true),
            _TableCell('تاريخ الترقية', isHeader: true),
          ]),
          TableRow(children: [_TableCell('أستاذ مشارك'), _TableCell('أستاذ مساعد'), _TableCell('2020')]),
        ],
      ),
    );
  }

  Widget _buildAttachmentsList(BuildContext context) {
    return Column(
      children: [
        ListTile(
          trailing: const Icon(Icons.picture_as_pdf, color: Colors.red),
          title: const Text('شهادة التخرج الموثقة.pdf', textAlign: TextAlign.right, style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildJudgeSelection(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(15),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(labelText: 'اختيار المحكم المختص'),
        items: const [DropdownMenuItem(value: '1', child: Text('د. سارة محمود'))],
        onChanged: (v) {},
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.verified_user),
          label: const Text('اعتماد وتحويل للمحكم'),
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;
  const _TableCell(this.text, {this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? theme.colorScheme.primary : null,
        ),
      ),
    );
  }
}
// 1. دالة جدول العبء التدريسي
  Widget _buildTeachingLoadTable(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Table(
        // استخدام اللون الذهبي من الثيم للحدود
        border: TableBorder.all(color: theme.colorScheme.secondary.withOpacity(0.2), width: 1),
        children: [
          TableRow(
            decoration: BoxDecoration(color: theme.colorScheme.secondary.withOpacity(0.05)),
            children: const [
              _TableCell('عدد الساعات', isHeader: true),
              _TableCell('اسم المقرر', isHeader: true),
            ],
          ),
          const TableRow(children: [_TableCell('4'), _TableCell('خوارزميات (CS301)')]),
          const TableRow(children: [_TableCell('4'), _TableCell('ذكاء اصطناعي (CS405)')]),
        ],
      ),
    );
  }

  // 2. دالة قائمة المرفقات
  Widget _buildAttachmentsList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
      child: Column(
        children: [
          _attachmentItem('شهادة التخرج الموثقة (PhD).pdf'),
          _attachmentItem('إثبات الدرجة الوظيفية الحالية.pdf'),
        ],
      ),
    );
  }

  // 3. ودجت عنصر المرفق الواحد
  Widget _attachmentItem(String name) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(name, style: const TextStyle(fontSize: 12, color: Colors.black87)),
          const SizedBox(width: 10),
          const Icon(Icons.picture_as_pdf, color: Color(0xFFC62828), size: 22),
        ],
      ),
    );
  }