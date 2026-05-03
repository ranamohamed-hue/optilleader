import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:optialeader/core/theming/app_color.dart';

class AddRefereePage extends StatefulWidget {
  const AddRefereePage({super.key});

  @override
  State<AddRefereePage> createState() => _AddRefereePageState();
}

class _AddRefereePageState extends State<AddRefereePage> {
  final _formKey = GlobalKey<FormState>();

  // الـ Controllers الخاصة بالمحكم
  final _nameAr = TextEditingController();
  final _nameEn = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _university = TextEditingController();
  final _specializationAr = TextEditingController();
  final _specializationEn = TextEditingController();
  final _academicRank = TextEditingController(); // الأستاذية، أستاذ مشارك.. إلخ

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("إضافة محكم علمي جديد")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- القسم الأول: البيانات الشخصية ---
              _buildSectionCard(
                context,
                "البيانات الشخصية",
                Icons.person_add_rounded,
                [
                  _buildField(
                    "الاسم بالكامل (عربي)",
                    _nameAr,
                    Icons.person,
                    (v) => v!.isEmpty ? "الاسم مطلوب" : null,
                  ),
                  SizedBox(height: 10.h),
                  _buildField(
                    "Full Name (English)",
                    _nameEn,
                    Icons.person_outline,
                    (v) => v!.isEmpty ? "Name required" : null,
                    isEn: true,
                  ),
                  SizedBox(height: 10.h),
                  _buildField(
                    "البريد الإلكتروني",
                    _email,
                    Icons.email,
                    (v) => !v!.contains('@') ? "إيميل غير صحيح" : null,
                  ),
                  SizedBox(height: 10.h),
                  _buildField(
                    "رقم الهاتف",
                    _phone,
                    Icons.phone_android,
                    (v) => v!.isEmpty ? "رقم الهاتف مطلوب" : null,
                  ),
                ],
              ),

              SizedBox(height: 10.h),

              // --- القسم الثاني: البيانات الأكاديمية ---
              // ... (نفس الـ Controllers والـ build الأساسي)

              // --- القسم الثاني: البيانات الأكاديمية (بعد التعديل) ---
              _buildSectionCard(
                context,
                "الخلفية الأكاديمية",
                Icons.history_edu,
                [
                  // 1. حقل الجامعة (تم إضافة الـ Validator)
                  _buildField(
                    "الجامعة / المؤسسة التابع لها",
                    _university,
                    Icons.account_balance,
                    (v) => v!.isEmpty ? "برجاء إدخال اسم الجامعة" : null,
                  ),

                  SizedBox(height: 10.h),

                  // 2. حقل الرتبة العلمية (تم إضافة الـ Validator)
                  _buildField(
                    "الرتبة العلمية (أستاذ، مشارك..)",
                    _academicRank,
                    Icons.military_tech,
                    (v) => v!.isEmpty ? "الرتبة العلمية مطلوبة" : null,
                  ),

                  SizedBox(height: 10.h),

                  // 3. حقل التخصص العربي (تم إضافة الـ Validator)
                  _buildField(
                    "التخصص الدقيق (عربي)",
                    _specializationAr,
                    Icons.biotech,
                    (v) => v!.isEmpty ? "التخصص العربي مطلوب" : null,
                  ),

                  SizedBox(height: 10.h),

                  // 4. حقل التخصص الإنجليزي (تم إضافة الـ Validator والـ isEn)
                  _buildField(
                    "Specialization (English)",
                    _specializationEn,
                    Icons.science_outlined,
                    (v) => v!.isEmpty ? "Specialization is required" : null,
                    isEn: true,
                  ),
                ],
              ),

              SizedBox(height: 30.h),

              // --- زر الحفظ ---
              SizedBox(
                width: double.infinity,
                height: 55.h,
                child: ElevatedButton(
                  style: theme.elevatedButtonTheme.style,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Logic الحفظ بكرة إن شاء الله
                    }
                  },
                  child: Text(
                    "اعتماد المحكم في النظام",
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.darkGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  // مساعد لبناء الكروت بنفس تصميم الـ Dashboard
  Widget _buildSectionCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Card(
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.navyDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    IconData icon,
    String? Function(String?)? validator, {
    bool isEn = false,
  }) {
    return TextFormField(
      controller: ctrl,
      validator: validator,
      textAlign: isEn ? TextAlign.left : TextAlign.right,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }
}
