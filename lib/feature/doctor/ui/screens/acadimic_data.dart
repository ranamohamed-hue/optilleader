import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_state.dart';

class DoctorProfileDataPage extends StatefulWidget {
  final String doctorUid; 

  const DoctorProfileDataPage({super.key, required this.doctorUid});

  @override
  State<DoctorProfileDataPage> createState() => _DoctorProfileDataPageState();
}

class _DoctorProfileDataPageState extends State<DoctorProfileDataPage> {

  @override
  void initState() {
    super.initState();
    // ✅ اللوجيك مربوط كويس هنا بجلب بيانات الدكتور
    context.read<DoctorDataCubit>().getDoctorProfile(widget.doctorUid);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<DoctorDataCubit, DoctorDataState>(
      builder: (context, state) {
        // 1. حالة التحميل
        if (state is DoctorLoading) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // 2. حالة عرض البيانات
        if (state is DoctorLoaded) {
          final doctor = state.doctor;

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 180.0.h,
                  pinned: true,
                  backgroundColor: colorScheme.primary,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, size: 20.sp, color: Colors.white),
                    onPressed: () {
                      if (context.canPop()) { context.pop(); } else { context.go(Routes.user); }
                    },
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.85)],
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
                                border: Border.all(color: colorScheme.secondary, width: 2.w),
                              ),
                              child: CircleAvatar(
                                radius: 35.r,
                                backgroundColor: Colors.white12,
                                backgroundImage: (doctor!.profileImage.isNotEmpty)
                                    ? CachedNetworkImageProvider(doctor.profileImage)
                                    : null,
                                child: (doctor.profileImage.isEmpty)
                                    ? Icon(Icons.person, color: colorScheme.secondary, size: 40.sp)
                                    : null,
                              ),
                            ),
                            SizedBox(width: 15.w),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.locale.languageCode == 'ar'
                                        ? (doctor.nameAr ?? 'dashboard.doctor_default'.tr())
                                        : (doctor.nameEn ?? 'dashboard.doctor_default'.tr()),
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.sp,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    doctor.currentJobAr ?? "acadimicData.personal_section".tr(),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white70, fontSize: 13.sp,
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
                SliverList(
                  delegate: SliverChildListDelegate([
                    SizedBox(height: 10.h),
                    _buildSectionCard(
                      context,
                      icon: Icons.badge_outlined,
                      // ✅ [تعديل] تطابق مع الـ JSON Key
                      title: "acadimicData.personal_section".tr(),
                      children: [
                        _buildInfoRow(context, label: "acadimicData.name_ar".tr(), value: doctor.nameAr ?? '-'),
                        _buildInfoRow(context, label: "acadimicData.phone".tr(), value: doctor.phone ?? '-'),
                        _buildInfoRow(context, label: "acadimicData.social_status".tr(), value: doctor.socialStatusAr ?? '-'),
                        // ✅ [تعديل] ترجمة كلمة نشط وغير نشط
                        _buildInfoRow(context, label: "statuses.active".tr(), value: (doctor.isActive) ? "statuses.active".tr() : "statuses.inactive".tr()),
                        _buildInfoRow(context, label: "acadimicData.birth_date".tr(), value: doctor.birthDate != null ? "${doctor.birthDate!.toLocal()}".split(' ')[0] : '-'),
                      ],
                    ),
                    _buildSectionCard(
                      context,
                      icon: Icons.school_outlined,
                      // ✅ [تعديل] تطابق مع الـ JSON Key
                      title: "acadimicData.academic_section".tr(),
                      children: [
                        _buildInfoRow(context, label: "acadimicData.job_ar".tr(), value: doctor.currentJobAr ?? '-'),
                      ],
                    ),
                    _buildSectionCard(
                      context,
                      icon: Icons.contact_mail_outlined,
                      // ✅ [تعديل] تطابق مع الـ JSON Key
                      title: "acadimicData.contact_section".tr(),
                      children: [
                        _buildInfoRow(context, label: "acadimicData.email".tr(), value: doctor.email ?? '-'),
                        _buildInfoRow(context, label: "acadimicData.address_ar".tr(), value: doctor.addressAr ?? '-'),
                      ],
                    ),
                    SizedBox(height: 40.h),
                  ]),
                ),
              ],
            ),
          );
        }

        // 3. حالة الخطأ
        if (state is DoctorError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48.sp),
                  SizedBox(height: 16.h),
                  Text(state.error ?? 'error_message'.tr(), style: TextStyle(color: Colors.red, fontSize: 14.sp)),
                  SizedBox(height: 20.h),
                  ElevatedButton(
                    onPressed: () {
                      // ✅ اللوجيك مربوط كويس هنا بإعادة المحاولة
                      context.read<DoctorDataCubit>().getDoctorProfile(widget.doctorUid);
                    },
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            ),
          );
        }

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget _buildSectionCard(BuildContext context, {required IconData icon, required String title, required List<Widget> children}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10.r, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: colorScheme.secondary, size: 22.sp),
              SizedBox(width: 10.w),
              Text(title, style: theme.textTheme.titleSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14.sp)),
            ]),
            Divider(height: 30.h, color: colorScheme.primary.withOpacity(0.1)),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, {required String label, required String value}) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary.withOpacity(0.7), fontWeight: FontWeight.w600, fontSize: 11.sp)),
          SizedBox(height: 4.h),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface, fontSize: 14.sp, fontWeight: FontWeight.w500)),
          SizedBox(height: 10.h),
          Divider(height: 1, color: theme.dividerColor.withOpacity(0.2)),
        ],
      ),
    );
  }
}