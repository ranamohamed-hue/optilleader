import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:optialeader/feature/auth/logic/cubits/auth_cubit.dart';
import 'package:optialeader/feature/auth/logic/cubits/auth_state.dart';
import 'package:optialeader/feature/auth/data/models/user_model.dart';
import 'package:optialeader/core/routing/routes.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isObscure = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logoscreen.jpeg',
                    height: 120.h,
                    width: 120.w,
                  ),
                  SizedBox(height: 20.h),

                  /// العنوان الرئيسي: OptiLeader
                  Text(
                    "OptiLeader", // نص مباشر أو مفتاح ترجمة لو متاح
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: const Color(0xFF000080), // Navy
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  /// العنوان الفرعي: Login
                  Text("Login".tr(), style: theme.textTheme.bodySmall),

                  SizedBox(height: 40.h),

                  /// EMAIL - ربطته بـ auth.fields.email
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "auth.fields.email".tr(),
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Required".tr();
                      if (!v.contains('@')) return "Invalid Email".tr();
                      return null;
                    },
                  ),

                  SizedBox(height: 20.h),

                  /// PASSWORD - ربطته بـ auth.fields.password
                  TextFormField(
                    controller: passwordController,
                    obscureText: isObscure,
                    decoration: InputDecoration(
                      labelText: "Password".tr(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isObscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => isObscure = !isObscure),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Required".tr();
                      if (v.length < 6) return "Password short".tr();
                      return null;
                    },
                  ),

                  SizedBox(height: 30.h),

                  /// زر الدخول الرئيسي: Login
                  BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state is LoginSuccessState) {
                        final role = state.userModel.role;
                        if (role == UserRole.admin)
                          context.go(Routes.admin);
                        else if (role == UserRole.judge)
                          context.go(Routes.judge);
                        else if (role == UserRole.database_admin)
                          context.go(Routes.databaseAdmin);
                        else
                          context.go(Routes.user);
                      } else if (state is LoginErrorState) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.error),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else if (state is NewUserFirstLoginState) {
                        context.go(Routes.changePassword);
                      }
                    },
                    builder: (context, state) {
                      if (state is LoginLoadingState) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthCubit>().login(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 52.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          "Login".tr(), // هيعرض "دخول"
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 20.h),

                  /// زر التسجيل: SignUp
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("No Account".tr()), // ليس لديك حساب؟
                      TextButton(
                        onPressed: () => context.push(Routes.register),
                        child: Text(
                          "Signup".tr(), // سجل الآن
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
