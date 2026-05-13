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
  final String? existingUid;

  const AddAdminPage({super.key, this.existingUid});

  @override
  State<AddAdminPage> createState() => _AddAdminPageState();
}

class _AddAdminPageState extends State<AddAdminPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _nameArController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _phoneController = TextEditingController();
  final _jobTitleArController = TextEditingController();
  final _jobTitleEnController = TextEditingController();
  final _addressArController = TextEditingController();
  final _addressEnController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _employeeIdController = TextEditingController();

  bool get isArabic => context.locale.languageCode == 'ar';
  bool get isEditing => widget.existingUid != null;

  // ✅ منع النقر المزدوج
  bool _isSubmitting = false;

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
    _nationalIdController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  /// ✅ ملء المتحكمات من بيانات المسؤول
  void _populateFields(AdminProfileModel admin) {
    _nameArController.text = admin.nameAr;
    _nameEnController.text = admin.nameEn;
    _emailController.text = admin.email;
    _phoneController.text = admin.phone;
    _jobTitleArController.text = admin.jopAr;
    _jobTitleEnController.text = admin.jopEn;
    _addressArController.text = admin.addressAr;
    _addressEnController.text = admin.addressEn;
    _nationalIdController.text = admin.nationalId;
    _employeeIdController.text = admin.employeeId;
    // ✅ لا حاجة لـ setState — المتحكمات تُحدّث الواجهة تلقائياً
  }

  void _onSavePressed(BuildContext context) {
    if (_isSubmitting) return; // ✅ منع النقر المزدوج

    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      final adminModel = AdminProfileModel(
        uid: '',
        email: _emailController.text.trim(),
        nameAr: _nameArController.text.trim(),
        nameEn: _nameEnController.text.trim(),
        jopAr: _jobTitleArController.text.trim(),
        jopEn: _jobTitleEnController.text.trim(),
        phone: _phoneController.text.trim(),
        addressAr: _addressArController.text.trim(),
        addressEn: _addressEnController.text.trim(),
        nationalId: _nationalIdController.text.trim(),
        employeeId: _employeeIdController.text.trim(),
        profileImage: "",
        isActive: true,
        role: 'admin',
        isFirstLogin: true,
      );

      if (isEditing) {
        final updatedAdmin = adminModel.copyWith(uid: widget.existingUid!);
        context.read<AdminDataCubit>().saveAdminData(updatedAdmin);
      } else {
        context.read<AdminDataCubit>().createNewAdmin(adminModel);
      }
    }
  }

  // ✅ محقق محسّن للرقم القومي
  String? _validateNationalId(String? value) {
    if (value == null || value.isEmpty) {
      return "add_admin.required".tr();
    }
    if (value.length != 14) {
      return "add_admin.valid_national_id".tr();
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return "add_admin.valid_national_id".tr();
    }
    return null;
  }

  // ✅ محقق محسّن للبريد الإلكتروني
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "add_admin.required".tr();
    }
    if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(value)) {
      return "add_admin.valid_email_format".tr();
    }
    return null;
  }

  String? _requiredField(String? value) {
    if (value == null || value.isEmpty) {
      return "add_admin.required".tr();
    }
    return null;
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
          _populateFields(state.admin!);
        } else if (state is AdminSuccess) {
          _isSubmitting = false; // ✅ إعادة تعيين حالة الزر

          // 1. إخفاء أي SnackBar قديم لمنع التراكم
          ScaffoldMessenger.of(context).clearSnackBars();

          // 2. عرض رسالة النجاح
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditing
                    ? "add_admin.edit_success_msg".tr()
                    : "add_admin.success_msg".tr(),
              ),
              backgroundColor: Colors.green,
            ),
          );

          // ✅ 3. [الحل الجذري للتهنيج] تأخير بسيط جداً ثم العودة للخلف بأمان
          Future.microtask(() {
            if (context.mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          });
        } else if (state is AdminError) {
          _isSubmitting = false; // ✅ إعادة تعيين بعد الخطأ
          setState(() {}); // ✅ ضروري لتحديث حالة الزر

          String errorMessage = state.error;
          if (state.error == "ERROR_EMAIL_ALREADY_IN_USE") {
            errorMessage = "add_admin.email_in_use".tr();
          } else if (state.error == "ERROR_WEAK_PASSWORD") {
            errorMessage = "add_admin.weak_password".tr();
          }

          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isEditing
                ? "add_admin.edit_app_bar_title"
                      .tr() // ✅ كان نص ثابت
                : "add_admin.app_bar_title".tr(),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        // ✅ إضافة BlocBuilder للتحقق من حالة التحميل الأولي
        body: BlocBuilder<AdminDataCubit, AdminDataState>(
          builder: (context, state) {
            // ✅ عرض مؤشر تحميل أثناء جلب البيانات في وضع التعديل
            if (isEditing && state is! AdminLoaded && state is! AdminError) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.darkGold),
              );
            }

            // ✅ عرض خطأ إذا فشل جلب البيانات
            if (isEditing && state is AdminError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60.sp,
                      color: AppColors.error,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      state.error,
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AdminDataCubit>().getAdminProfile(
                          widget.existingUid!,
                        );
                      },
                      child: Text("retry".tr()),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
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
                          (v) => v!.isEmpty
                              ? "add_admin.valid_name_ar".tr()
                              : null,
                        ),
                        _buildTextField(
                          "add_admin.name_en".tr(),
                          _nameEnController,
                          Icons.person_outline,
                          (v) => v!.isEmpty
                              ? "add_admin.valid_name_en".tr()
                              : null,
                          isEn: true,
                        ),
                        _buildTextField(
                          "add_admin.email".tr(),
                          _emailController,
                          Icons.email_outlined,
                          _validateEmail, // ✅ محقق محسّن
                          isEn: true,
                        ),
                        _buildTextField(
                          "add_admin.phone".tr(),
                          _phoneController,
                          Icons.phone,
                          _requiredField, // ✅ دالة موحدة
                          keyboardType: TextInputType.phone,
                          isEn: true,
                        ),
                        _buildTextField(
                          "add_admin.national_id".tr(), // ✅ كان نص ثابت
                          _nationalIdController,
                          Icons.badge,
                          _validateNationalId, // ✅ محقق محسّن
                          keyboardType: TextInputType.number,
                          isEn: true,
                          maxLength: 14,
                        ),
                        _buildTextField(
                          "add_admin.employee_id".tr(), // ✅ كان نص ثابت
                          _employeeIdController,
                          Icons.work_history,
                          _requiredField, // ✅ كان نص ثابت
                          keyboardType: TextInputType.number,
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
                          (v) =>
                              v!.isEmpty ? "add_admin.valid_job_ar".tr() : null,
                        ),
                        _buildTextField(
                          "add_admin.job_en".tr(),
                          _jobTitleEnController,
                          Icons.work_outline,
                          (v) =>
                              v!.isEmpty ? "add_admin.valid_job_en".tr() : null,
                          isEn: true,
                        ),
                        _buildTextField(
                          "add_admin.address_ar".tr(),
                          _addressArController,
                          Icons.location_on,
                          _requiredField,
                        ),
                        _buildTextField(
                          "add_admin.address_en".tr(),
                          _addressEnController,
                          Icons.location_on_outlined,
                          _requiredField,
                          isEn: true,
                        ),
                      ],
                    ),
                    SizedBox(height: 30.h),
                    _buildSaveButton(state), // ✅ فصل الزر
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ✅ فصل زر الحفظ لدالة مستقلة
  Widget _buildSaveButton(AdminDataState state) {
    final isLoading = state is AdminLoading || _isSubmitting;

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
        onPressed: isLoading ? null : () => _onSavePressed(context),
        child: isLoading
            ? SizedBox(
                width: 24.w,
                height: 24.w,
                child: const CircularProgressIndicator(
                  color: AppColors.darkGold,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                isEditing
                    ? "add_admin.save_changes"
                          .tr() // ✅ كان نص ثابت
                    : "add_admin.submit_button".tr(),
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.darkGold,
                  fontWeight: FontWeight.bold,
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
    int? maxLength, // ✅ إضافة حد أقصى للطول
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLength: maxLength,
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
          counterText: '', // ✅ إخفاء عداد الأحرف
        ),
      ),
    );
  }
}
