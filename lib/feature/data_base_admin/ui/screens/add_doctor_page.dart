import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:optialeader/core/theming/app_color.dart';

import 'package:optialeader/core/theming/app_text_style.dart';

class AddDoctorPage extends StatefulWidget {
  const AddDoctorPage({super.key});

  @override
  State<AddDoctorPage> createState() => _AddDoctorPageState();
}

class _AddDoctorPageState extends State<AddDoctorPage> {
  // 1. التحكم في النصوص (Controllers)
  final _nameAr = TextEditingController();
  final _nameEn = TextEditingController();
  final _nationalityAr = TextEditingController();
  final _nationalityEn = TextEditingController();
  final _currentJobAr = TextEditingController();
  final _currentJobEn = TextEditingController();
  final _nationalId = TextEditingController();
  final _employeeId = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _addressAr = TextEditingController();
  final _addressEn = TextEditingController();

  DateTime? birthDate;

  // الحالة الاجتماعية
  final List<String> statusAr = ["أعزب", "متزوج", "أرمل", "مطلق"];
  final List<String> statusEn = ["Single", "Married", "Widowed", "Divorced"];
  String? selectedStatusAr;
  String? selectedStatusEn;

  // التاريخ الأكاديمي
  List<Map<String, dynamic>> academicHistory = [];

  // الأهلية
  bool isOnVacation = false;
  bool hasPermanentPosition = true;
  bool disciplinaryClearance = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor, // مربوط بـ AppColors.lightBackground
      appBar: AppBar(
        title: Text(
          "استمارة بيانات الدكتور الشاملة",
          style: theme.appBarTheme.titleTextStyle,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // --- بيانات الهوية والوظيفة ---
            _buildSectionCard(
              "بيانات الهوية والوظيفة الحالية",
              Icons.person_pin_rounded,
              [
                _buildVerticalDoubleField(
                  "الاسم بالكامل (عربي)",
                  _nameAr,
                  "Full Name (English)",
                  _nameEn,
                  Icons.person,
                ),
                SizedBox(height: 15.h),
                _buildVerticalDoubleField(
                  "الجنسية (عربي)",
                  _nationalityAr,
                  "Nationality (English)",
                  _nationalityEn,
                  Icons.flag,
                ),
                SizedBox(height: 15.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(
                        "الحالة الاجتماعية",
                        statusAr,
                        selectedStatusAr,
                        (val) => setState(() => selectedStatusAr = val),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _buildDropdownField(
                        "Social Status",
                        statusEn,
                        selectedStatusEn,
                        (val) => setState(() => selectedStatusEn = val),
                        isEn: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
                _buildVerticalDoubleField(
                  "الوظيفة الحالية (عربي)",
                  _currentJobAr,
                  "Current Job (English)",
                  _currentJobEn,
                  Icons.work,
                ),
                SizedBox(height: 15.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        "الرقم القومي",
                        _nationalId,
                        Icons.badge,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _buildField(
                        "الرقم الوظيفي",
                        _employeeId,
                        Icons.work_history,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
                _buildDatePicker(
                  "تاريخ الميلاد",
                  birthDate,
                  (date) => setState(() => birthDate = date),
                ),
              ],
            ),

            // --- بيانات التواصل والعنوان ---
            _buildSectionCard("بيانات التواصل والعنوان", Icons.contact_phone, [
              _buildField(
                "البريد الجامعي الرسمي",
                _email,
                Icons.alternate_email,
              ),
              _buildField("رقم الهاتف الشخصي", _phone, Icons.phone_android),
              SizedBox(height: 15.h),
              _buildVerticalDoubleField(
                "العنوان بالتفصيل (عربي)",
                _addressAr,
                "Address Details (English)",
                _addressEn,
                Icons.location_on,
              ),
            ]),

            // --- التاريخ الأكاديمي ---
            _buildSectionCard("التاريخ الأكاديمي والوظيفي", Icons.school, [
              ...academicHistory
                  .asMap()
                  .entries
                  .map((entry) => _buildAcademicEntry(entry.key))
                  .toList(),
              SizedBox(height: 10.h),
              Center(
                child: OutlinedButton.icon(
                  onPressed: () => setState(
                    () => academicHistory.add({
                      'degree': '',
                      'major': '',
                      'date': '',
                      'place': '',
                    }),
                  ),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text("إضافة درجة علمية سابقة"),
                  style: theme.outlinedButtonTheme.style,
                ),
              ),
            ]),

            // --- مراجعة الأهلية ---
            _buildSectionCard("مراجعة الأهلية", Icons.verified_user, [
              _buildSwitch(
                "خلو من الجزاءات التأديبية",
                disciplinaryClearance,
                (v) => setState(() => disciplinaryClearance = v),
              ),
              _buildSwitch(
                "يشغل وظيفة دائمة بالجامعة",
                hasPermanentPosition,
                (v) => setState(() => hasPermanentPosition = v),
              ),
              _buildSwitch(
                "هل الدكتور في إجازة حالياً؟",
                isOnVacation,
                (v) => setState(() => isOnVacation = v),
              ),
            ]),

            SizedBox(height: 30.h),

            // --- زرار الحفظ الملكي ---
            SizedBox(
              width: double.infinity,
              height: 60.h,
              child: ElevatedButton(
                style: theme.elevatedButtonTheme.style,
                onPressed: () {
                  // هنا يتم ربط الموديل لاحقاً
                },
                child: Text(
                  "حفظ ملف الدكتور بالكامل",
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.darkGold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  // --- Widgets مساعدة مربوطة بالثيم الخاص بكِ ---

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      margin: EdgeInsets.only(bottom: 20.h),
      // سيسحب الـ shape (BorderRadius 25) من CardTheme
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.darkGold),
                SizedBox(width: 10.w),
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.navyDark,
                  ),
                ),
              ],
            ),
            const Divider(height: 30, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    IconData? icon, {
    bool isEn = false,
  }) {
    return TextFormField(
      controller: ctrl,
      textAlign: isEn ? TextAlign.left : TextAlign.right,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.navyDark),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> items,
    String? value,
    Function(String?) onChanged, {
    bool isEn = false,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: isEn ? null : const Icon(Icons.favorite),
      ),
      items: items
          .map(
            (s) => DropdownMenuItem(
              value: s,
              child: Text(s, style: AppTextStyles.bodySmall),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildAcademicEntry(int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: AppColors.navyLight.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColors.navyLight.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildSmallInput(
            "الدرجة العلمية",
            (v) => academicHistory[index]['degree'] = v,
          ),
          SizedBox(height: 8.h),
          _buildSmallInput(
            "التخصص",
            (v) => academicHistory[index]['major'] = v,
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildSmallInput(
                  "السنة",
                  (v) => academicHistory[index]['date'] = v,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildSmallInput(
                  "الجامعة",
                  (v) => academicHistory[index]['place'] = v,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.delete_sweep, color: AppColors.error),
              onPressed: () => setState(() => academicHistory.removeAt(index)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallInput(String hint, Function(String) onChanged) {
    return TextField(
      onChanged: onChanged,
      style: AppTextStyles.bodySmall,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime? date,
    Function(DateTime) onPick,
  ) {
    return InkWell(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime(1985),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date == null ? label : "${date.year}-${date.month}-${date.day}",
              style: AppTextStyles.bodyMedium,
            ),
            const Icon(Icons.calendar_month, color: AppColors.navyDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch(String t, bool v, Function(bool) c) => SwitchListTile(
    title: Text(t, style: AppTextStyles.bodyMedium),
    value: v,
    onChanged: c,
  );

  Widget _buildVerticalDoubleField(
    String labelAr,
    TextEditingController ctrlAr,
    String labelEn,
    TextEditingController ctrlEn,
    IconData icon,
  ) {
    return Column(
      children: [
        _buildField(labelAr, ctrlAr, icon),
        SizedBox(height: 8.h),
        _buildField(labelEn, ctrlEn, null, isEn: true),
      ],
    );
  }
}
