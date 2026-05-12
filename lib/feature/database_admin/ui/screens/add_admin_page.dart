import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:optialeader/core/theming/app_color.dart';
import 'package:optialeader/core/theming/app_text_style.dart';
import 'package:optialeader/feature/database_admin/data/models/admin_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/admin_data/admin_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/admin_data/admin_data_state.dart';
import 'dart:ui' as ui;

class AddAdminPage extends StatefulWidget {
  final String? existingUid; // للتعديل من البحث

  const AddAdminPage({super.key, this.existingUid});

  @override
  State<AddAdminPage> createState() => _AddAdminPageState();
}

class _AddAdminPageState extends State<AddAdminPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _emailController = TextEditingController();
  final _nameArController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _phoneController = TextEditingController();
  final _jobTitleArController = TextEditingController();
  final _jobTitleEnController = TextEditingController();
  final _addressArController = TextEditingController();
  final _addressEnController = TextEditingController();

  // 🟢 [إضافة] كنترولرز الرقم القومي والوظيفي
  final _nationalIdController = TextEditingController();
  final _employeeIdController = TextEditingController();

  bool get isArabic => context.locale.languageCode == 'ar';
  bool get isEditing => widget.existingUid != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      context.read<AdminDataCubit>().getAdminProfile(widget.existingUid!);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameArController.dispose();
    _nameEnController.dispose();
    _phoneController.dispose();
    _jobTitleArController.dispose();
    _jobTitleEnController.dispose();
    _addressArController.dispose();
    _addressEnController.dispose();
    _nationalIdController.dispose(); // 🟢 [إضافة]
    _employeeIdController.dispose(); // 🟢 [إضافة]
    super.dispose();
  }

  void _onSavePressed(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final String uidToSave = isEditing
          ? widget.existingUid!
          : FirebaseFirestore.instance.collection('Users').doc().id;

      final adminModel = AdminProfileModel(
        uid: uidToSave,
        email: _emailController.text.trim(),
        nameAr: _nameArController.text.trim(),
        nameEn: _nameEnController.text.trim(),
        jopAr: _jobTitleArController.text.trim(),
        jopEn: _jobTitleEnController.text.trim(),
        phone: _phoneController.text.trim(),
        addressAr: _addressArController.text.trim(),
        addressEn: _addressEnController.text.trim(),
        nationalId: _nationalIdController.text.trim(), // 🟢 [إضافة]
        employeeId: _employeeIdController.text.trim(), // 🟢 [إضافة]
        profileImage: "",
        isActive: true,
        role: 'admin',
        isFirstLogin: true,
      );

      context.read<AdminDataCubit>().saveAdminData(adminModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminDataCubit, AdminDataState>(
      listenWhen: (previous, current) =>
          current is AdminSuccess ||
          current is AdminError ||
          current is AdminLoaded,
      listener: (context, state) {
        if (state is AdminLoaded) {
          final admin = state.admin!;
          _nameArController.text = admin.nameAr;
          _nameEnController.text = admin.nameEn;
          _emailController.text = admin.email;
          _phoneController.text = admin.phone;
          _jobTitleArController.text = admin.jopAr;
          _jobTitleEnController.text = admin.jopEn;
          _addressArController.text = admin.addressAr;
          _addressEnController.text = admin.addressEn;
          _nationalIdController.text = admin.nationalId; // 🟢 [إضافة]
          _employeeIdController.text = admin.employeeId; // 🟢 [إضافة]
          setState(() {});
        } else if (state is AdminSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditing ? "تم التعديل بنجاح" : "add_admin.success_msg".tr(),
              ),
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
        appBar: AppBar(
          title: Text(
            isEditing ? "تعديل بيانات المسؤول" : "add_admin.app_bar_title".tr(),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // القسم الأول: البيانات الشخصية
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
                      (v) =>
                          !RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(v!)
                          ? "add_admin.valid_email_format".tr()
                          : null,
                      isEn: true,
                    ),
                    _buildTextField(
                      "add_admin.phone".tr(),
                      _phoneController,
                      Icons.phone,
                      (v) => v!.isEmpty ? "add_admin.required".tr() : null,
                      keyboardType: TextInputType.phone,
                      isEn: true,
                    ),
                    // 🟢 [إضافة] حقل الرقم القومي
                    _buildTextField(
                      "الرقم القومي",
                      _nationalIdController,
                      Icons.badge,
                      (v) => v!.isEmpty ? "هذا الحقل مطلوب" : null,
                      keyboardType: TextInputType.number,
                      isEn: true,
                    ),
                    // 🟢 [إضافة] حقل الرقم الوظيفي
                    _buildTextField(
                      "الرقم الوظيفي",
                      _employeeIdController,
                      Icons.work_history,
                      (v) => v!.isEmpty ? "هذا الحقل مطلوب" : null,
                      keyboardType: TextInputType.number,
                      isEn: true,
                    ),
                  ],
                ),

                // القسم الثاني: بيانات العمل
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
                    _buildTextField(
                      "add_admin.address_ar".tr(),
                      _addressArController,
                      Icons.location_on,
                      (v) => v!.isEmpty ? "add_admin.required".tr() : null,
                    ),
                    _buildTextField(
                      "add_admin.address_en".tr(),
                      _addressEnController,
                      Icons.location_on_outlined,
                      (v) => v!.isEmpty ? "add_admin.required".tr() : null,
                      isEn: true,
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
                                isEditing
                                    ? "حفظ التعديلات"
                                    : "add_admin.submit_button".tr(),
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
        textAlign: isEn
            ? TextAlign.left
            : (isArabic ? TextAlign.right : TextAlign.left),
        textDirection: isEn
            ? ui.TextDirection.ltr
            : (isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr),
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20.sp, color: AppColors.navyLight),
          labelStyle: AppTextStyles.bodySmall,
          alignLabelWithHint: true,
        ),
      ),
    );
  }
}
