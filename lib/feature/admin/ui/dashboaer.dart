import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:optialeader/feature/database_admin/data/models/admin_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/admin_data/admin_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/admin_data/admin_data_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";

    return BlocListener<AdminDataCubit, AdminDataState>(
      listener: (context, state) {
        if (state is AdminError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: BlocBuilder<AdminDataCubit, AdminDataState>(
          builder: (context, state) {
            if (state is AdminLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AdminLoaded) {
              final admin = state.admin!;

              bool isArabic = context.locale.languageCode == 'ar';

              String displayName = isArabic ? admin.nameAr : admin.nameEn;

              String displayJob = isArabic ? admin.jopAr : admin.jopEn;

              return SafeArea(
                child: Column(
                  children: [
                    /// HEADER
                    Container(
                      padding: EdgeInsets.all(25.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.primary,
                            colorScheme.primaryContainer,
                          ],
                        ),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(30.r),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'dashboard.welcome'.tr(args: [displayName]),
                                style: textTheme.titleLarge?.copyWith(
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                              Text(
                                displayJob.isNotEmpty
                                    ? displayJob
                                    : 'dashboard.system_admin'.tr(),
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onPrimary.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                          CircleAvatar(
                            radius: 28.r,
                            backgroundColor: colorScheme.surface,
                            child: ClipOval(
                              child: admin.profileImage.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: admin.profileImage,
                                      width: 56.r,
                                      height: 56.r,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) =>
                                          const CircularProgressIndicator(),
                                      errorWidget: (_, __, ___) =>
                                          const Icon(Icons.person),
                                    )
                                  : const Icon(Icons.person),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    /// CONTENT
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          children: [
                            /// New Requests
                            _card(
                              context,
                              title: 'dashboard.new_requests'.tr(),
                              icon: Icons.note_add_rounded,
                              value: '15',
                              color: colorScheme.primary,
                            ),

                            SizedBox(height: 15.h),

                            /// Under Review
                            _card(
                              context,
                              title: 'dashboard.under_review'.tr(),
                              icon: Icons.gavel_rounded,
                              value: '08',
                              color: colorScheme.secondary,
                            ),

                            SizedBox(height: 15.h),

                            /// Add Announcement
                            _card(
                              context,
                              title: 'dashboard.add_announcement'.tr(),
                              icon: Icons.campaign_rounded,
                              value: '+',
                              color: Colors.orange,
                            ),
                          ],
                        ),
                      ),
                    ),

                    /// SIDEBAR
                    Container(
                      height: 70.h,
                      color: colorScheme.primary,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.person),
                            color: Colors.white,
                            onPressed: () =>
                                context.push('/admin/admin_setting'),
                          ),

                          IconButton(
                            icon: const Icon(Icons.search),
                            color: Colors.white,
                            onPressed: () => context.push('/admin/user_search'),
                          ),

                          IconButton(
                            icon: const Icon(Icons.notifications),
                            color: Colors.white,
                            onPressed: () {},
                          ),

                          IconButton(
                            icon: const Icon(Icons.logout),
                            color: Colors.red,
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              if (context.mounted) {
                                context.go('/login');
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            /// ERROR / EMPTY
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('dashboard.no_data'.tr()),
                  SizedBox(height: 10.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AdminDataCubit>().getAdminProfile(
                        currentUid,
                      );
                    },
                    child: Text('dashboard.retry'.tr()),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Row(
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 10.w),
              Icon(icon, color: color),
            ],
          ),
        ],
      ),
    );
  }
}
