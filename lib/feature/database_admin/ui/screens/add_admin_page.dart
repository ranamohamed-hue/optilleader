import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart'; // إضافة المكتبة
import 'package:optialeader/core/theming/app_color.dart';
import 'package:optialeader/core/theming/app_text_style.dart';
import 'package:optialeader/feature/database_admin/data/models/admin_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/admin_data/admin_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/admin_data/admin_data_state.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class AddAdminPage extends StatefulWidget {
  const AddAdminPage({super.key});

  @override
  State<AddAdminPage> createState() => _AddAdminPageState();
}

class _AddAdminPageState extends State<AddAdminPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _emailController = TextEditingController();
  final _nameArController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _jobTitleArController = TextEditingController();
  final _jobTitleEnController = TextEditingController();
  final _addressArController = TextEditingController();
  final _addressEnController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _nameArController.dispose();
    _nameEnController.dispose();
    _nationalIdController.dispose();
    _employeeIdController.dispose();
    _jobTitleArController.dispose();
    _jobTitleEnController.dispose();
    _addressArController.dispose();
    _addressEnController.dispose();
    super.dispose();
  }

  void _onSavePressed(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final adminModel = AdminProfileModel(
        uid: "",
        email: _emailController.text.trim(),
        nameAr: _nameArController.text.trim(),
        nameEn: _nameEnController.text.trim(),
        jobAr: _jobTitleArController.text.trim(),
        jobEn: _jobTitleEnController.text.trim(),
        phone: _nationalIdController.text.trim(),
        addressAr: _addressArController.text.trim(),
        addressEn: _addressEnController.text.trim(),
        profileImage: "",
        isActive: true,
      );

      context.read<AdminDataCubit>().saveAdminData(adminModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AdminDataCubit, AdminDataState>(
      listenWhen: (previous, current) =>
          current is AdminSuccess || current is AdminError,
      listener: (context, state) {
        if (state is AdminSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("add_admin.success_msg".tr()),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state is AdminError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text("add_admin.app_bar_title".tr()),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildSectionCard(
                  "add_admin.personal_info_section".tr(),
                  Icons.admin_panel_settings,
                  [
                    _buildTextField(
                      "add_admin.name_ar".tr(),
                      _nameArController,
                      Icons.person,
                      (v) => v!.isEmpty ? "add_admin.valid_name_ar".tr() : null,
                    ),
                    _buildTextField(
                      "add_admin.name_en".tr(),
                      _nameEnController,
                      Icons.person_outline,
                      (v) => v!.isEmpty ? "add_admin.valid_name_en".tr() : null,
                      isEn: true,
                    ),
                    _buildTextField(
                      "add_admin.email".tr(),
                      _emailController,
                      Icons.email_outlined,
                      (v) {
                        if (v!.isEmpty) return "add_admin.valid_email_req".tr();
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(v)) {
                          return "add_admin.valid_email_format".tr();
                        }
                        return null;
                      },
                      isEn: true,
                    ),
                  ],
                ),
                _buildSectionCard(
                  "add_admin.job_info_section".tr(),
                  Icons.business_center,
                  [
                    _buildTextField(
                      "add_admin.job_ar".tr(),
                      _jobTitleArController,
                      Icons.work,
                      (v) => v!.isEmpty ? "add_admin.valid_job_ar".tr() : null,
                    ),
                    _buildTextField(
                      "add_admin.job_en".tr(),
                      _jobTitleEnController,
                      Icons.work_outline,
                      (v) => v!.isEmpty ? "add_admin.valid_job_en".tr() : null,
                      isEn: true,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            "add_admin.national_id".tr(),
                            _nationalIdController,
                            Icons.badge,
                            (v) => v!.length != 14
                                ? "add_admin.valid_id_length".tr()
                                : null,
                            keyboardType: TextInputType.number,
                            isEn: true, // الأرقام يفضل تكون بنظام LTR
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _buildTextField(
                            "add_admin.employee_id".tr(),
                            _employeeIdController,
                            Icons.numbers,
                            (v) => v!.isEmpty
                                ? "add_admin.valid_emp_id".tr()
                                : null,
                            keyboardType: TextInputType.number,
                            isEn: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 30.h),
                BlocBuilder<AdminDataCubit, AdminDataState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      height: 55.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navyDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: state is AdminLoading
                            ? null
                            : () => _onSavePressed(context),
                        child: state is AdminLoading
                            ? const CircularProgressIndicator(
                                color: AppColors.darkGold,
                              )
                            : Text(
                                "add_admin.submit_button".tr(),
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.darkGold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.r),
        side: BorderSide(color: AppColors.navyLight.withOpacity(0.1)),
      ),
      margin: EdgeInsets.only(bottom: 20.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.darkGold, size: 22.sp),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.navyDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 25, thickness: 0.5),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    String? Function(String?)? validator, {
    bool isEn = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        // تحسين: ضبط اتجاه النص بناءً على نوع الحقل (عربي/إنجليزي)
        textAlign: isEn ? TextAlign.left : TextAlign.right,
        textDirection: isEn ? ui.TextDirection.ltr : ui.TextDirection.rtl,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20.sp),
          labelStyle: AppTextStyles.bodySmall,
        ),
      ),
    );
  }
}
