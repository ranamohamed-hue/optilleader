import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/routing/routes.dart';

class DoctorProfileDataPage extends StatefulWidget {
  const DoctorProfileDataPage({super.key});

  @override
  State<DoctorProfileDataPage> createState() => _DoctorProfileDataPageState();
}

class _DoctorProfileDataPageState extends State<DoctorProfileDataPage> {
  // التجهيز لاستقبال البيانات والتحكم بها
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController statusController;
  late TextEditingController birthDateController;
  late TextEditingController jobController;
  late TextEditingController emailController;
  late TextEditingController addressController;

  @override
  void initState() {
    super.initState();
    // تهيئة الـ Controllers
    nameController = TextEditingController();
    phoneController = TextEditingController();
    statusController = TextEditingController();
    birthDateController = TextEditingController();
    jobController = TextEditingController();
    emailController = TextEditingController();
    addressController = TextEditingController();

    // هنا يمكنك استدعاء بيانات الطبيب من الـ Cubit وتعيين القيم للـ Controllers
    // مثال: nameController.text = "د. سارة محمد";
  }

  @override
  void dispose() {
    // تنظيف الـ Controllers من الذاكرة
    nameController.dispose();
    phoneController.dispose();
    statusController.dispose();
    birthDateController.dispose();
    jobController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header (SliverAppBar)
          SliverAppBar(
            expandedHeight: 180.0.h,
            pinned: true,
            backgroundColor: colorScheme.primary,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: 20.sp,
                color: Colors.white,
              ),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(Routes.user);
                }
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.85),
                    ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 80.h, 20.w, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.secondary,
                            width: 2.w,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 35.r,
                          backgroundColor: Colors.white12,
                          child: Icon(
                            Icons.person,
                            color: colorScheme.secondary,
                            size: 40.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Dr. Sara Mohamed", // يمكن استبدالها بـ Controller لاحقاً
                              style: textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "add_doctor.personal_section".tr(),
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                                fontSize: 13.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content Area
          SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: 10.h),

              // 1. General Information Card
              _buildSectionCard(
                context,
                icon: Icons.badge_outlined,
                title: "add_doctor.personal_section".tr(),
                children: [
                  _buildField(
                    context,
                    label: "add_doctor.name_ar".tr(),
                    controller: nameController,
                    hint: "add_doctor.name_ar".tr(),
                  ),
                  _buildField(
                    context,
                    label: "add_doctor.phone".tr(),
                    controller: phoneController,
                    hint: "+20 123 456 789",
                    keyboardType: TextInputType.phone,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          context,
                          label: "add_doctor.social_status".tr(),
                          controller: statusController,
                          hint: "...",
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildField(
                          context,
                          label: "statuses.active".tr(),
                          controller: TextEditingController(
                            text: "Active",
                          ), // حقل ثابت للعرض فقط
                          enabled: false,
                          hint: "Active",
                        ),
                      ),
                    ],
                  ),
                  _buildField(
                    context,
                    label: "add_doctor.birth_date".tr(),
                    controller: birthDateController,
                    hint: "DD/MM/YYYY",
                  ),
                ],
              ),

              // 2. Academic & Career History
              _buildSectionCard(
                context,
                icon: Icons.school_outlined,
                title: "add_doctor.academic_section".tr(),
                children: [
                  _buildField(
                    context,
                    label: "add_doctor.job_ar".tr(),
                    controller: jobController,
                    hint: "Enter job...",
                  ),
                ],
              ),

              // 3. Contact Details
              _buildSectionCard(
                context,
                icon: Icons.contact_mail_outlined,
                title: "add_doctor.contact_section".tr(),
                children: [
                  _buildField(
                    context,
                    label: "add_doctor.email".tr(),
                    controller: emailController,
                    hint: "sara@university.edu.eg",
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildField(
                    context,
                    label: "add_doctor.address_ar".tr(),
                    controller: addressController,
                    hint: "City, District, St.",
                  ),
                ],
              ),

              // Save Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // هنا نجمع البيانات من الـ controllers ونرسلها للـ Cubit
                      // print(nameController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      "add_doctor.save_btn".tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40.h),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.secondary, size: 22.sp),
                SizedBox(width: 10.w),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
            Divider(height: 30.h, color: colorScheme.primary.withOpacity(0.1)),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    String? hint,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 8.h),
          TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 15.w,
                vertical: 12.h,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
