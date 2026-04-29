import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:optialeader/feature/admin/logic/admin_cubit.dart';
import 'package:optialeader/feature/admin/logic/admin_state.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  late TextEditingController addressController;
  late TextEditingController phone1Controller;
  late TextEditingController phone2Controller;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    addressController = TextEditingController();
    phone1Controller = TextEditingController();
    phone2Controller = TextEditingController();
  }

  @override
  void dispose() {
    addressController.dispose();
    phone1Controller.dispose();
    phone2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BlocListener<AdminCubit, AdminState>(
      listener: (context, state) {
        if (state is AdminSuccess && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('إعدادات الملف الشخصي'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<AdminCubit, AdminState>(
          builder: (context, state) {
            if (state is AdminLoading && !isInitialized) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AdminSuccess) {
              final admin = state.admin;

              if (!isInitialized) {
                addressController.text = admin.info.addressAr;
                phone1Controller.text = admin.info.phone1;
                phone2Controller.text = admin.info.phone2;
                isInitialized = true;
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    /// 🔵 Profile Image Header
                    _buildHeader(
                      colorScheme,
                      admin.info.profileImage,
                      admin.uid,
                    ),

                    SizedBox(height: 60.h),

                    /// 🟢 Input Fields Group
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(
                            "بيانات الحساب (غير قابلة للتعديل)",
                            textTheme,
                          ),
                          _buildInputField(
                            theme,
                            icon: Icons.person_outline,
                            label: 'اسم المستخدم',
                            initialValue: admin.username,
                            enabled: false,
                          ),
                          _buildInputField(
                            theme,
                            icon: Icons.email_outlined,
                            label: 'البريد الجامعي',
                            initialValue: admin.email,
                            enabled: false,
                          ),

                          SizedBox(height: 20.h),
                          _buildLabel("البيانات الشخصية", textTheme),
                          _buildInputField(
                            theme,
                            icon: Icons.location_on_outlined,
                            label: 'العنوان',
                            controller: addressController,
                          ),
                          _buildInputField(
                            theme,
                            icon: Icons.phone_android_outlined,
                            label: 'الهاتف الأساسي',
                            controller: phone1Controller,
                            keyboardType: TextInputType.phone,
                          ),
                          _buildInputField(
                            theme,
                            icon: Icons.phone_outlined,
                            label: 'الهاتف الإضافي',
                            controller: phone2Controller,
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30.h),

                    /// 🔵 Action Button
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: state is AdminLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: () => _saveData(admin.uid),
                              child: const Text("حفظ التغييرات"),
                            ),
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  void _saveData(String uid) {
    context.read<AdminCubit>().updateAdminData(
      uid: uid,
      address: addressController.text,
      phone1: phone1Controller.text,
      phone2: phone2Controller.text,
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, String imageUrl, String uid) {
    return Container(
      height: 120.h,
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
            bottom: -50.h,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.surface, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 55.r,
                    backgroundColor: colorScheme.secondary.withOpacity(0.1),
                    backgroundImage: imageUrl.isNotEmpty
                        ? NetworkImage(imageUrl)
                        : null,
                    child: imageUrl.isEmpty
                        ? Icon(
                            Icons.person,
                            size: 50.r,
                            color: colorScheme.primary,
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {}, // سيتم إضافة Pick Image لاحقاً
                    child: CircleAvatar(
                      radius: 18.r,
                      backgroundColor: colorScheme.secondary,
                      child: Icon(
                        Icons.camera_alt,
                        size: 18.r,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, TextTheme textTheme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h, right: 5.w),
      child: Text(
        text,
        style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInputField(
    ThemeData theme, {
    required String label,
    required IconData icon,
    TextEditingController? controller,
    String? initialValue,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: TextFormField(
        controller:
            controller ??
            (initialValue != null
                ? TextEditingController(text: initialValue)
                : null),
        enabled: enabled,
        keyboardType: keyboardType,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: enabled
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurface.withOpacity(0.5),
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20.r),
          labelText: label,
          // الثيم سيتكفل بالباقي (Borders, Padding, إلخ)
        ),
      ),
    );
  }
}
