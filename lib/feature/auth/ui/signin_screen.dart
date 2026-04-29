import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:optialeader/feature/auth/logic/cubits/auth_cubit.dart';
import 'package:optialeader/feature/auth/logic/cubits/auth_state.dart';

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
                  /// LOGO
                  Image.asset(
                    'assets/images/logoscreen.jpeg',
                    height: 120.h,
                    width: 120.w,
                  ),

                  SizedBox(height: 20.h),

                  /// TITLE
                  Text(
                    "auth.login_title".tr(),
                    style: theme.textTheme.displayLarge,
                  ),

                  SizedBox(height: 8.h),

                  Text(
                    "auth.login_subtitle".tr(),
                    style: theme.textTheme.bodySmall,
                  ),

                  SizedBox(height: 40.h),

                  /// EMAIL
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "auth.university_email".tr(),
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Required";
                      }
                      if (!v.contains('@')) {
                        return "Invalid email";
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 20.h),

                  /// PASSWORD
                  TextFormField(
                    controller: passwordController,
                    obscureText: isObscure,
                    decoration: InputDecoration(
                      labelText: "auth.password".tr(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isObscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            isObscure = !isObscure;
                          });
                        },
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Required";
                      }
                      if (v.length < 6) {
                        return "Password too short";
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 30.h),

                  /// BUTTON + STATE
                  BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) {
                      /// ERROR
                      if (state is LoginErrorState) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(state.error)));
                      }
                      /// FIRST LOGIN
                      else if (state is NewUserFirstLoginState) {
                        debugPrint("First login detected");

                        /// 🔥 مفيش navigation هنا
                        /// go_router هيعمل redirect
                      }
                      /// RESET PASSWORD SUCCESS
                      else if (state is PasswordResetSuccessState) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(state.message)));
                      }
                      /// RESET PASSWORD ERROR
                      else if (state is PasswordResetErrorState) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(state.error)));
                      }
                    },
                    builder: (context, state) {
                      /// LOADING
                      if (state is LoginLoadingState) {
                        return SizedBox(
                          width: double.infinity,
                          height: 52.h,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
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
                          "auth.login_button".tr(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 20.h),

                  /// SIGNUP
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("auth.dont_have_account".tr()),
                      TextButton(
                        onPressed: () {
                          context.push('/register'); // ✅ go_router
                        },
                        child: Text(
                          "auth.signup_button".tr(),
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
