import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:optialeader/feature/auth/data/models/user_model.dart';
import 'package:optialeader/feature/auth/logic/cubits/auth_cubit.dart';
import 'package:optialeader/feature/auth/logic/cubits/auth_state.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final PageController _pageController = PageController();

  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();

  // STEP 1
  final emailController = TextEditingController();
  final nationalIdController = TextEditingController();
  final employeeIdController = TextEditingController();

  // STEP 2
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  int _currentStep = 0;
  UserModel? verifiedUser;
  bool isPasswordHidden = true;

  @override
  void dispose() {
    _pageController.dispose();
    emailController.dispose();
    nationalIdController.dispose();
    employeeIdController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _verifyUser() {
    if (_formKeyStep1.currentState!.validate()) {
      context.read<AuthCubit>().verifyUser(
        email: emailController.text.trim(),
        nationalId: nationalIdController.text.trim(),
        employeeId: employeeIdController.text.trim(),
      );
    }
  }

  void _submit() {
    if (verifiedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يجب التحقق من البيانات أولاً")),
      );
      return;
    }

    if (_formKeyStep2.currentState!.validate()) {
      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("auth.validation.password_mismatch".tr())),
        );
        return;
      }

      context.read<AuthCubit>().signUp(
        userModel: verifiedUser!,
        password: passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Create an account".tr()),
        centerTitle: true,
        leading: _currentStep == 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() => _currentStep = 0);
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              )
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is VerifySuccessState) {
            verifiedUser = state.user;
            setState(() => _currentStep = 1);
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else if (state is VerifyErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          } else if (state is SignUpSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("تم إنشاء الحساب بنجاح"),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context); // العودة لصفحة الدخول
          } else if (state is SignUpErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [_buildStep1(state, theme), _buildStep2(state, theme)],
          );
        },
      ),
    );
  }

  /// المرحلة الأولى: التحقق من الهوية
  Widget _buildStep1(AuthState state, ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Form(
        key: _formKeyStep1,
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Text(
              "Confirm identity".tr(), // "تأكيد الهوية"
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30.h),
            _buildField(
              emailController,
              "University Email".tr(),
              isEmail: true,
              icon: Icons.email_outlined,
            ),
            _buildField(
              nationalIdController,
              "national Id".tr(),
              isNumber: true,
              icon: Icons.badge_outlined,
            ),
            _buildField(
              employeeIdController,
              "employee id".tr(),
              isNumber: true,
              icon: Icons.numbers,
            ),
            SizedBox(height: 40.h),
            if (state is VerifyLoadingState)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _verifyUser,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 52.h),
                ),
                child: Text("Next".tr()), // "التالي"
              ),
          ],
        ),
      ),
    );
  }

  /// المرحلة الثانية: تعيين كلمة المرور
  Widget _buildStep2(AuthState state, ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Form(
        key: _formKeyStep2,
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Text(
              "Set a password".tr(), // "تعيين كلمة المرور"
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30.h),
            _buildField(
              passwordController,
              "Enter your password".tr(),
              isPassword: true,
              icon: Icons.lock_outline,
            ),
            _buildField(
              confirmPasswordController,
              "Confirm password".tr(),
              isPassword: true,
              icon: Icons.lock_reset,
            ),
            SizedBox(height: 40.h),
            if (state is SignUpLoadingState)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 52.h),
                ),
                child: Text("Complete registration".tr()), // "إتمام التسجيل"
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    bool isPassword = false,
    bool isEmail = false,
    bool isNumber = false,
    IconData? icon,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? isPasswordHidden : false,
        keyboardType: isNumber
            ? TextInputType.number
            : (isEmail ? TextInputType.emailAddress : TextInputType.text),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => isPasswordHidden = !isPasswordHidden),
                )
              : null,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Required".tr();
          }
          if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return "Invalid_email".tr();
          }
          if (isPassword && value.length < 6) {
            return "Password short".tr();
          }
          return null;
        },
      ),
    );
  }
}
