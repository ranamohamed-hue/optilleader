import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/feature/setting/data/models/user_setting_model.dart';
import 'package:optialeader/feature/setting/logic/setting_cubit.dart';
import 'package:optialeader/feature/setting/logic/setting_state.dart';

class SettingsScreen extends StatefulWidget {
  final String uid;
  final String role;

  const SettingsScreen({super.key, required this.uid, required this.role});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController addressController;
  late TextEditingController phone1Controller;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    addressController = TextEditingController();
    phone1Controller = TextEditingController();

    context.read<SettingCubit>().getUserData(
      uid: widget.uid,
      role: widget.role,
    );
  }

  @override
  void dispose() {
    addressController.dispose();
    phone1Controller.dispose();
    super.dispose();
  }

  void _onSavePressed(UserSettingsModel? user) {
    if (user != null) {
      // ✅ استخدام copyWith لتعديل الحقول المطلوبة فقط
      final updatedData = user.copyWith(
        addressAr: addressController.text.trim(),
        phone: phone1Controller.text.trim(),
      );

      context.read<SettingCubit>().updateUserData(
        user: updatedData,
        role: widget.role,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // ✅ معرفة لغة التطبيق الحالية لعرض الاسم المناسب
    final isArabic = context.locale.languageCode == 'ar';

    return BlocListener<SettingCubit, SettingState>(
      listener: (context, state) {
        if (state is SettingFetchSuccess) {
          if (!isInitialized) {
            addressController.text = state.user.addressAr;
            phone1Controller.text = state.user.phone;
            isInitialized = true;
          }
        } else if (state is SettingUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('settings.success'.tr()),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is SettingError) {
          // ✅ ترجمة أكواد الأخطاء القادمة من الـ Cubit
          String errorMessage = state.message;
          if (state.message == "ERROR_USER_NOT_FOUND") {
            errorMessage = "settings.error_user_not_found".tr();
          } else if (state.message == "ERROR_DB_CONNECTION" ||
              state.message == "ERROR_DB_UPDATE") {
            errorMessage = "settings.error_db".tr();
          } else if (state.message == "ERROR_UNKNOWN") {
            errorMessage = "settings.error_unknown".tr();
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage), // ✅ عرض الرسالة المترجمة
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, size: 20.sp),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(Routes.user);
              }
            },
          ),
          title: Text('settings.title'.tr()),
          centerTitle: true,
        ),
        body: BlocBuilder<SettingCubit, SettingState>(
          builder: (context, state) {
            if (state is SettingLoading && !isInitialized) {
              return Center(
                child: CircularProgressIndicator(color: colorScheme.secondary),
              );
            }

            final user = (state is SettingFetchSuccess) ? state.user : null;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildHeader(context, user?.profileImage ?? ""),
                  SizedBox(height: 60.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        _buildInputField(
                          context: context,
                          label: 'settings.username'.tr(),
                          icon: Icons.person_outline,
                          // ✅ عرض الاسم بناءً على لغة التطبيق الحالية
                          initialValue: isArabic
                              ? (user?.nameAr ?? "...")
                              : (user?.nameEn ?? "..."),
                          enabled: false,
                        ),
                        _buildInputField(
                          context: context,
                          label: 'settings.email'.tr(),
                          icon: Icons.email_outlined,
                          initialValue: user?.email ?? "...",
                          enabled: false,
                        ),
                        _buildInputField(
                          context: context,
                          label: 'settings.address'.tr(),
                          icon: Icons.location_on_outlined,
                          controller: addressController,
                        ),
                        _buildInputField(
                          context: context,
                          label: 'settings.phone'.tr(),
                          icon: Icons.phone_android_outlined,
                          controller: phone1Controller,
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 30.h),
                        state is SettingLoading && isInitialized
                            ? CircularProgressIndicator(
                                color: colorScheme.primary,
                              )
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _onSavePressed(user),
                                  child: Text("settings.save".tr()),
                                ),
                              ),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String imageUrl) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 100.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40.r)),
      ),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: -45.h,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.secondary, width: 3.w),
              ),
              child: CircleAvatar(
                radius: 50.r,
                backgroundColor: colorScheme.surface,
                child: CircleAvatar(
                  radius: 47.r,
                  backgroundImage: imageUrl.isNotEmpty
                      ? NetworkImage(imageUrl)
                      : null,
                  child: imageUrl.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 45.sp,
                          color: colorScheme.primary,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required BuildContext context,
    required String label,
    required IconData icon,
    TextEditingController? controller,
    String? initialValue,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: TextFormField(
        controller: controller,
        initialValue: controller == null ? initialValue : null,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 22.sp),
        ),
      ),
    );
  }
}
