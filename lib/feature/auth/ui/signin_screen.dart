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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// Logo
                  Image.asset(
                    'assets/images/logoscreen.jpeg',
                    height: 120.h,
                    width: 120.w,
                  ),
                  SizedBox(height: 20.h),

                  Text(
                    "OptiLeader",
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: const Color(0xFF000080),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  /// Subtitle (NEW)
                  Text(
                    "login.subtitle".tr(),
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 40.h),

                  /// Email Field
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "fields.email".tr(),
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "validation.required".tr();
                      }
                      if (!v.contains('@')) {
                        return "validation.invalid_email".tr();
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 20.h),

                  /// Password Field
                  TextFormField(
                    controller: passwordController,
                    obscureText: isObscure,
                    decoration: InputDecoration(
                      labelText: "fields.password".tr(),
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
                      if (v == null || v.isEmpty) {
                        return "validation.required".tr();
                      }
                      if (v.length < 8) {
                        return "validation.password_short".tr();
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 40.h),

                  /// Login Button
                  BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state is LoginSuccessState) {
                        final role = state.userModel.role;

                        if (role == UserRole.admin) {
                          context.go(Routes.admin);
                        } else if (role == UserRole.judge) {
                          context.go(Routes.judge);
                        } else if (role == UserRole.database_admin) {
                          context.go(Routes.databaseAdmin);
                        } else {
                          context.go(Routes.user);
                        }
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
                        return const CircularProgressIndicator();
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
                          backgroundColor: const Color(0xFF000080),
                          minimumSize: Size(double.infinity, 52.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          "login.button".tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      );
                    },
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
