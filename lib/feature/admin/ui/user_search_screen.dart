import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/routing/routes.dart'; 
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_state.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DoctorDataCubit>().watchAllDoctors();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('search.app_bar_title'.tr()),
          leading: IconButton(
  icon: Icon(Icons.arrow_back_ios_new, size: 20.sp),
  onPressed: () {
    if (context.canPop()) {
      context.pop(); 
    } else {
      context.go(Routes.admin); 
    }
  },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.h),
          child: Container(color: colorScheme.secondary, height: 2.h),
        ),
      ),
      body: Column(
        children: [
          // حقل البحث
          Padding(
            padding: EdgeInsets.all(20.w),
            child: TextField(
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'search.hint'.tr(),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) {},
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: _buildSectionHeader(
              context,
              'search.employee_services'.tr(),
            ),
          ),

          // عرض البيانات المربوطة بالكيوبيت
          Expanded(
            child: BlocBuilder<DoctorDataCubit, DoctorDataState>(
              builder: (context, state) {
                if (state is DoctorLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AllDoctorLoaded) {
                  final doctors = state.doctors;

                  if (doctors == null || doctors.isEmpty) {
                    return Center(child: Text('search.no_users'.tr()));
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      return _buildDoctorCard(context, doctors[index]);
                    },
                  );
                }

                if (state is DoctorError) {
                  return Center(
                    child: Text(
                      'search.error_message'.tr(args: [state.error.toString()]),
                    ),
                  );
                }

                return Center(child: Text('search.loading'.tr()));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, DoctorProfileModel doctor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: () {
          // context.push('/doctor_details', extra: doctor);
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          doctor.nameAr,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          doctor.currentJobAr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12.sp,
                          ),
                        ),
                        Text(
                          'search.employee_id_label'.tr(
                            args: [doctor.employeeId],
                          ), // ترجمة الرقم الوظيفي
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 15.w),
                  _buildProfileImage(colorScheme, doctor.profileImageUrl),
                ],
              ),
              Divider(height: 25.h, thickness: 0.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    doctor.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12.sp,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Icon(
                    Icons.email_outlined,
                    color: colorScheme.secondary,
                    size: 18.sp,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(ColorScheme colorScheme, String? imageUrl) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colorScheme.secondary, width: 2),
      ),
      child: CircleAvatar(
        radius: 30.r,
        backgroundColor: colorScheme.surfaceVariant,
        backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
            ? NetworkImage(imageUrl)
            : null,
        child: (imageUrl == null || imageUrl.isEmpty)
            ? Icon(Icons.person, color: colorScheme.primary, size: 30.sp)
            : null,
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 8.w),
          Icon(
            Icons.label_important_outline,
            color: theme.colorScheme.secondary,
            size: 20.sp,
          ),
        ],
      ),
    );
  }
}
