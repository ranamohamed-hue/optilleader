import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
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

  /// ================= VERIFY =================
  void _verifyUser() {
    if (_formKeyStep1.currentState!.validate()) {
      context.read<AuthCubit>().verifyUser(
        email: emailController.text.trim(),
        nationalId: nationalIdController.text.trim(),
        employeeId: employeeIdController.text.trim(),
      );
    }
  }

  /// ================= SIGN UP =================
  void _submit() {
    if (verifiedUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("لازم يتم التحقق الأول")));
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
    return Scaffold(
      appBar: AppBar(
        title: Text("auth.registration_title".tr()),
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

      /// 🔥 BlocConsumer
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          /// ✅ VERIFY SUCCESS
          if (state is VerifySuccessState) {
            verifiedUser = state.user;

            setState(() => _currentStep = 1);

            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
          /// ❌ VERIFY ERROR
          else if (state is VerifyErrorState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
          /// ✅ SIGN UP SUCCESS
          else if (state is SignUpSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("تم إنشاء الحساب بنجاح"),
                backgroundColor: Colors.green,
              ),
            );
          }
          /// ❌ SIGN UP ERROR
          else if (state is SignUpErrorState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },

        builder: (context, state) {
          return PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [_buildStep1(state), _buildStep2(state)],
          );
        },
      ),
    );
  }

  // ================= STEP 1 =================
  Widget _buildStep1(AuthState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKeyStep1,
        child: Column(
          children: [
            const SizedBox(height: 30),

            Text(
              "auth.step_1_title".tr(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            _buildField(
              emailController,
              "auth.university_email".tr(),
              isEmail: true,
            ),

            _buildField(
              nationalIdController,
              "auth.national_id".tr(),
              isNumber: true,
            ),

            _buildField(
              employeeIdController,
              "auth.employee_id".tr(),
              isNumber: true,
            ),

            const SizedBox(height: 30),

            if (state is VerifyLoadingState)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _verifyUser,
                child: Text("auth.next".tr()),
              ),
          ],
        ),
      ),
    );
  }

  // ================= STEP 2 =================
  Widget _buildStep2(AuthState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKeyStep2,
        child: Column(
          children: [
            const SizedBox(height: 30),

            Text(
              "auth.step_2_title".tr(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            _buildField(
              passwordController,
              "auth.password".tr(),
              isPassword: true,
            ),

            _buildField(
              confirmPasswordController,
              "auth.confirm_password".tr(),
              isPassword: true,
            ),

            const SizedBox(height: 40),

            if (state is SignUpLoadingState)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _submit,
                child: Text("auth.submit".tr()),
              ),
          ],
        ),
      ),
    );
  }

  // ================= FIELD =================
  Widget _buildField(
    TextEditingController controller,
    String label, {
    bool isPassword = false,
    bool isEmail = false,
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? isPasswordHidden : false,
        keyboardType: isNumber
            ? TextInputType.number
            : (isEmail ? TextInputType.emailAddress : TextInputType.text),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordHidden = !isPasswordHidden;
                    });
                  },
                )
              : null,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "auth.validation.required".tr();
          }

          if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return "auth.validation.invalid_email".tr();
          }

          if (isPassword && value.length < 6) {
            return "auth.validation.password_short".tr();
          }

          return null;
        },
      ),
    );
  }
}
