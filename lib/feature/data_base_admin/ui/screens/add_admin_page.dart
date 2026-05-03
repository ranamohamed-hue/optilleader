import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:optialeader/core/theming/app_color.dart';

class AddAdminPage extends StatefulWidget {
  const AddAdminPage({super.key});

  @override
  State<AddAdminPage> createState() => _AddAdminPageState();
}

class _AddAdminPageState extends State<AddAdminPage> {
  final _formKey = GlobalKey<FormState>();

  // الـ Controllers اللي عندك
  final _emailController = TextEditingController();
  final _nameArController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _jobTitleArController = TextEditingController();
  final _jobTitleEnController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("إضافة مسؤول إداري جديد")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey, // ربط الفورم بالمفتاح
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, "البيانات الأساسية"),
              _buildTextField(
                "الاسم بالعربية",
                _nameArController,
                Icons.person,
                (v) => v!.isEmpty ? "برجاء إدخال الاسم" : null,
              ),
              _buildTextField(
                "الاسم بالإنجليزية",
                _nameEnController,
                Icons.person_outline,
                (v) => v!.isEmpty ? "Please enter name" : null,
              ),
              _buildTextField("البريد الجامعي", _emailController, Icons.email, (
                v,
              ) {
                if (v!.isEmpty) return "الإيميل مطلوب";
                if (!v.contains('@')) return "صيغة البريد غير صحيحة";
                return null;
              }),

              SizedBox(height: 20.h),
              _buildSectionTitle(context, "بيانات العمل"),
              _buildTextField(
                "المسمى الوظيفي (عربي)",
                _jobTitleArController,
                Icons.work,
                (v) => v!.isEmpty ? "الحقل مطلوب" : null,
              ),
              _buildTextField(
                "المسمى الوظيفي (إنجليزي)",
                _jobTitleEnController,
                Icons.work_outline,
                (v) => v!.isEmpty ? "Field required" : null,
              ),
              _buildTextField(
                "الالرقم القومي",
                _nationalIdController,
                Icons.badge,
                (v) =>
                    v!.length != 14 ? "الرقم القومي يجب أن يكون 14 رقم" : null,
              ),
              _buildTextField(
                "كود الموظف",
                _employeeIdController,
                Icons.numbers,
                (v) => v!.isEmpty ? "الكود مطلوب" : null,
              ),

              SizedBox(height: 40.h),

              SizedBox(
                width: double.infinity,
                height: 55.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // لو البيانات تمام، هننفذ الرفع هنا
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("جاري حفظ البيانات...")),
                      );
                    }
                  },
                  child: Text(
                    "حفظ وإرسال البيانات",
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.darkGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.navyDark,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    String? Function(String?)? validator,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: TextFormField(
        controller: controller,
        validator: validator, // إضافة مصحح الأخطاء
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      ),
    );
  }
}
