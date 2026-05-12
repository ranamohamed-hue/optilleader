import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:optialeader/core/theming/app_color.dart';
import 'package:optialeader/core/theming/app_text_style.dart';
import 'package:optialeader/feature/database_admin/data/models/judge_profile_model.dart'; // تأكد إن المودل موجود
import 'package:optialeader/feature/database_admin/logic/judge_data/judge_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/judge_data/judge_data_state.dart';
import 'dart:ui' as ui;

class AddJudgePage extends StatefulWidget {
  final String? existingUid; // 🟢 لاستقبال الـ UID لو جايين من البحث للتعديل

  const AddJudgePage({super.key, this.existingUid});

  @override
  State<AddJudgePage> createState() => _AddJudgePageState();
}

class _AddJudgePageState extends State<AddJudgePage> {
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
  final _nationalIdController = TextEditingController();
  final _employeeIdController = TextEditingController();

  bool get isArabic => context.locale.languageCode == 'ar';
  
  // 🟢 متغير يحدد هل إحنا بنضيف جديد ولا بنعدل على موجود
  bool get isEditing => widget.existingUid != null;

  @override
  void initState() {
    super.initState();
    // 🟢 لو بنعدل، نجيب الداتا القديمة
    if (isEditing) {
      context.read<JudgeDataCubit>().getJudgeProfile(widget.existingUid!);
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

  void _onSavePressed(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // 🟢 لو بنعدل نستخدم الـ ID القديم، ولو بنضيف نولد ID جديد
      final String uidToSave = isEditing 
          ? widget.existingUid! 
          : FirebaseFirestore.instance.collection('users').doc().id;

      final judgeModel = JudgeProfileModel(
        uid: uidToSave,
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
        role: 'judge', // 🟢 الرتبة ثابتة judge
        isFirstLogin: true,
      );

      context.read<JudgeDataCubit>().saveJudgeData(judgeModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JudgeDataCubit, JudgeDataState>(
      listenWhen: (previous, current) =>
          current is JudgeSuccess || current is JudgeError || current is JudgeLoaded,
      listener: (context, state) {
        if (state is JudgeLoaded) {
          // 🟢 تعبئة الفيلدات بالداتا القديمة لما تيجي من البحث
          final judge = state.judge!;
          _nameArController.text = judge.nameAr;
          _nameEnController.text = judge.nameEn;
          _emailController.text = judge.email;
          _phoneController.text = judge.phone;
          _jobTitleArController.text = judge.jopAr;
          _jobTitleEnController.text = judge.jopEn;
          _addressArController.text = judge.addressAr;
          _addressEnController.text = judge.addressEn;
          _nationalIdController.text = judge.nationalId;
          _employeeIdController.text = judge.employeeId;
          setState(() {}); // تحديث الشاشة
        } 
        else if (state is JudgeSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing ? "تم التعديل بنجاح" : "تم إضافة المحكم بنجاح"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state is JudgeError) {
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
          title: Text(isEditing ? "تعديل بيانات المحكم" : "إضافة محكم جديد"), // 🟢
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
                  "البيانات الشخصية",
                  Icons.gavel,
                  [
                    _buildTextField(
                      "الاسم بالعربي",
                      _nameArController,
                      Icons.person,
                      (v) => v!.isEmpty ? "هذا الحقل مطلوب" : null,
                    ),
                    _buildTextField(
                      "الاسم بالإنجليزي",
                      _nameEnController,
                      Icons.person_outline,
                      (v) => v!.isEmpty ? "هذا الحقل مطلوب" : null,
                      isEn: true,
                    ),
                    _buildTextField(
                      "البريد الإلكتروني",
                      _emailController,
                      Icons.email_outlined,
                      (v) =>
                          !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v!)
                              ? "صيغة البريد غير صحيحة"
                              : null,
                      isEn: true,
                    ),
                    _buildTextField(
                      "رقم الهاتف",
                      _phoneController,
                      Icons.phone,
                      (v) => v!.isEmpty ? "هذا الحقل مطلوب" : null,
                      keyboardType: TextInputType.phone,
                      isEn: true,
                    ),
                    _buildTextField(
                      "الرقم القومي",
                      _nationalIdController,
                      Icons.badge,
                      (v) => v!.isEmpty ? "هذا الحقل مطلوب" : null,
                      keyboardType: TextInputType.number,
                      isEn: true,
                    ),
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
                  "بيانات العمل",
                  Icons.business_center,
                  [
                    _buildTextField(
                      "المسمى الوظيفي (عربي)",
                      _jobTitleArController,
                      Icons.work,
                      (v) => v!.isEmpty ? "هذا الحقل مطلوب" : null,
                    ),
                    _buildTextField(
                      "المسمى الوظيفي (إنجليزي)",
                      _jobTitleEnController,
                      Icons.work_outline,
                      (v) => v!.isEmpty ? "هذا الحقل مطلوب" : null,
                      isEn: true,
                    ),
                    _buildTextField(
                      "العنوان (عربي)",
                      _addressArController,
                      Icons.location_on,
                      (v) => v!.isEmpty ? "هذا الحقل مطلوب" : null,
                    ),
                    _buildTextField(
                      "العنوان (إنجليزي)",
                      _addressEnController,
                      Icons.location_on_outlined,
                      (v) => v!.isEmpty ? "هذا الحقل مطلوب" : null,
                      isEn: true,
                    ),
                  ],
                ),

                SizedBox(height: 30.h),

                // زر الحفظ
                BlocBuilder<JudgeDataCubit, JudgeDataState>(
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
                        onPressed: state is JudgeLoading
                            ? null
                            : () => _onSavePressed(context),
                        child: state is JudgeLoading
                            ? const CircularProgressIndicator(color: AppColors.darkGold)
                            : Text(
                                isEditing ? "حفظ التعديلات" : "إضافة المحكم", // 🟢
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

  // --- Widgets المساعدة ---
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