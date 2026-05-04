import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:optialeader/feature/auth/logic/cubits/auth_cubit.dart';
import 'package:optialeader/feature/auth/logic/cubits/auth_state.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isObscure = true;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Password mismatch".tr()),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      context.read<AuthCubit>().completeFirstLogin(
        newPassword: passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Change password".tr()), // "تغيير كلمة المرور"
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is UpdatePasswordErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is UpdatePasswordSuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
                // هنا ممكن تضيفي توجيه للصفحة الرئيسية بعد النجاح
              }
            },
            builder: (context, state) {
              return Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 40.h),

                    /// العنوان: تعيين كلمة مرور جديدة
                    Text(
                      "Change password".tr(),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF000080), // Navy
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 12.h),

                    /// النص الفرعي: هذا مطلوب عند تسجيل دخولك الأول
                    Text(
                      "Change password".tr(),
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 40.h),

                    /// حقل كلمة المرور الجديدة
                    _buildPasswordField(
                      controller: passwordController,
                      label: "New password".tr(),
                      isObscure: isObscure,
                      onToggle: () => setState(() => isObscure = !isObscure),
                    ),

                    SizedBox(height: 20.h),

                    /// حقل تأكيد كلمة المرور
                    _buildPasswordField(
                      controller: confirmPasswordController,
                      label: "Confirm New Password".tr(),
                      isObscure: isObscure,
                      // بنستخدم نفس الـ toggle للاتنين عشان التسهيل
                    ),

                    SizedBox(height: 40.h),

                    /// زر التأكيد
                    if (state is UpdatePasswordLoadingState)
                      const CircularProgressIndicator()
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                          
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            "Password Submit".tr(), // "تأكيد"
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isObscure,
    VoidCallback? onToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        suffixIcon: onToggle != null
            ? IconButton(
                icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
                onPressed: onToggle,
              )
            : null,
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return "auth.validation.required".tr();
        if (v.length < 6) return "Password short".tr();
        return null;
      },
    );
  }
}
