import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart'; // تأكدي من وجود الـ import
import 'package:optialeader/core/theming/app_color.dart';
import 'package:optialeader/feature/database_admin/data/models/judge_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/judge_data/judge_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/judge_data/judge_data_state.dart';

class AdJudgePage extends StatefulWidget {
  const AdJudgePage({super.key});

  @override
  State<AdJudgePage> createState() => _AdJudgePageState();
}

class _AdJudgePageState extends State<AdJudgePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameAr = TextEditingController();
  final _nameEn = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _university = TextEditingController();
  final _specializationAr = TextEditingController();
  final _specializationEn = TextEditingController();
  final _academicRank = TextEditingController();
  final _addressArController = TextEditingController();
  final _addressEnController = TextEditingController();

  @override
  void dispose() {
    _nameAr.dispose();
    _nameEn.dispose();
    _email.dispose();
    _phone.dispose();
    _university.dispose();
    _specializationAr.dispose();
    _specializationEn.dispose();
    _academicRank.dispose();
    _addressArController.dispose();
    _addressEnController.dispose();
    super.dispose();
  }

  void _saveJudge() {
    if (_formKey.currentState!.validate()) {
      final newJudge = JudgeProfileModel(
        uid: "",
        email: _email.text.trim(),
        nameAr: _nameAr.text.trim(),
        nameEn: _nameEn.text.trim(),
        jobAr:
            "${_academicRank.text} - ${_specializationAr.text} - ${_university.text}",
        jobEn:
            "${_academicRank.text} - ${_specializationEn.text} - ${_university.text}",
        phone: _phone.text.trim(),
        addressAr: _addressArController.text.trim(),
        addressEn: _addressEnController.text.trim(),
        profileImage: "",
        isActive: true,
      );

      context.read<JudgeDataCubit>().saveJudgeData(newJudge);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<JudgeDataCubit, JudgeDataState>(
      listenWhen: (previous, current) =>
          current is JudgeSuccess || current is JudgeError,
      listener: (context, state) {
        if (state is JudgeSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("add_judge.success_msg".tr()),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state is JudgeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? "add_judge.error_msg".tr()),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(title: Text("add_judge.title".tr())),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionCard(
                  context,
                  "add_judge.personal_section".tr(),
                  Icons.person_add_rounded,
                  [
                    _buildField(
                      "add_judge.name_ar".tr(),
                      _nameAr,
                      Icons.person,
                      (v) => v!.isEmpty ? "add_judge.val_name_ar".tr() : null,
                    ),
                    SizedBox(height: 10.h),
                    _buildField(
                      "add_judge.name_en".tr(),
                      _nameEn,
                      Icons.person_outline,
                      (v) => v!.isEmpty ? "add_judge.val_name_en".tr() : null,
                      isEn: true,
                    ),
                    SizedBox(height: 10.h),
                    _buildField(
                      "add_judge.email".tr(),
                      _email,
                      Icons.email,
                      (v) =>
                          !v!.contains('@') ? "add_judge.val_email".tr() : null,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 10.h),
                    _buildField(
                      "add_judge.phone".tr(),
                      _phone,
                      Icons.phone_android,
                      (v) => v!.isEmpty ? "add_judge.val_phone".tr() : null,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 10.h),
                    _buildField(
                      "add_judge.address_ar".tr(),
                      _addressArController,
                      Icons.location_on,
                      (v) =>
                          v!.isEmpty ? "add_judge.val_address_ar".tr() : null,
                    ),
                    SizedBox(height: 10.h),
                    _buildField(
                      "add_judge.address_en".tr(),
                      _addressEnController,
                      Icons.location_on_outlined,
                      (v) =>
                          v!.isEmpty ? "add_judge.val_address_en".tr() : null,
                      isEn: true,
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                _buildSectionCard(
                  context,
                  "add_judge.academic_section".tr(),
                  Icons.history_edu,
                  [
                    _buildField(
                      "add_judge.university".tr(),
                      _university,
                      Icons.account_balance,
                      (v) =>
                          v!.isEmpty ? "add_judge.val_university".tr() : null,
                    ),
                    SizedBox(height: 10.h),
                    _buildField(
                      "add_judge.rank".tr(),
                      _academicRank,
                      Icons.military_tech,
                      (v) => v!.isEmpty ? "add_judge.val_rank".tr() : null,
                    ),
                    SizedBox(height: 10.h),
                    _buildField(
                      "add_judge.spec_ar".tr(),
                      _specializationAr,
                      Icons.biotech,
                      (v) => v!.isEmpty ? "add_judge.val_spec_ar".tr() : null,
                    ),
                    SizedBox(height: 10.h),
                    _buildField(
                      "add_judge.spec_en".tr(),
                      _specializationEn,
                      Icons.science_outlined,
                      (v) => v!.isEmpty ? "add_judge.val_spec_en".tr() : null,
                      isEn: true,
                    ),
                  ],
                ),
                SizedBox(height: 30.h),
                BlocBuilder<JudgeDataCubit, JudgeDataState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      height: 55.h,
                      child: ElevatedButton(
                        onPressed: state is JudgeLoading ? null : _saveJudge,
                        child: state is JudgeLoading
                            ? const CircularProgressIndicator(
                                color: AppColors.darkGold,
                              )
                            : Text("add_judge.save_btn".tr()),
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

  // بقية الـ Widgets (_buildSectionCard, _buildField) تفضل زي ما هي بس استدعيها بـ tr()
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
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: ctrl,
      validator: validator,
      keyboardType: keyboardType,
      textAlign: isEn ? TextAlign.left : TextAlign.right,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }
}
