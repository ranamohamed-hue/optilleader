import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';

class AnnouncementDetailsDoctorPage extends StatefulWidget {
  final String announcementId;
  const AnnouncementDetailsDoctorPage({
    super.key,
    required this.announcementId,
  });

  @override
  State<AnnouncementDetailsDoctorPage> createState() =>
      _AnnouncementDetailsDoctorPageState();
}

class _AnnouncementDetailsDoctorPageState
    extends State<AnnouncementDetailsDoctorPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('announcements')
          .doc(widget.announcementId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: CircularProgressIndicator(color: colorScheme.secondary),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: Text('announcement_details.title'.tr())),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60.sp, color: Colors.grey),
                  SizedBox(height: 10.h),
                  Text('announcement_details.not_found'.tr()),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final announcement = AnnouncementModel.fromMap(
          data,
          widget.announcementId,
        );

        final String currentLang = context.locale.languageCode;
        final String title =
            data['title_$currentLang'] ??
            data['title'] ??
            'announcement_details.no_title'.tr();
        final String description =
            data['description_$currentLang'] ??
            data['description'] ??
            'announcement_details.no_description'.tr();
        final String? imageUrl = data['imageUrl'];

        final Timestamp? deadlineTimestamp = data['deadline'];
        final Timestamp? createdAtTimestamp = data['createdAt'];

        String formattedDeadline = '';
        if (deadlineTimestamp != null)
          formattedDeadline = DateFormat(
            'EEEE, d MMMM yyyy',
            currentLang,
          ).format(deadlineTimestamp.toDate());

        String postedDate = '';
        if (createdAtTimestamp != null)
          postedDate = DateFormat(
            'd MMM yyyy',
            currentLang,
          ).format(createdAtTimestamp.toDate());

        return Scaffold(
          backgroundColor: theme.primaryColor,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              final currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser == null) return;

              // ✅✅ شلنا الدرجات الثابتة، وبنبعت بس الإعلان والـ ID، والصفحة الجاية هتحسب من الـ Cubit
              context.push(
                Routes.doctorNominationRequest,
                extra: {
                  'announcement': announcement,
                  'doctorId': currentUser.uid,
                },
              );
            },
            elevation: 4,
            backgroundColor: colorScheme.secondary,
            icon: Icon(Icons.send_rounded, color: colorScheme.primary),
            label: Text(
              "announce.details.apply_button".tr(),
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: imageUrl != null ? 159.0.h : 80.0.h,
                pinned: true,
                automaticallyImplyLeading: false,
                backgroundColor: colorScheme.primary,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(35),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (imageUrl != null)
                        CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: Colors.black12),
                          errorWidget: (context, url, error) => Container(
                            color: colorScheme.primary.withOpacity(0.1),
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: colorScheme.primary,
                              size: 40.sp,
                            ),
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(
                                imageUrl != null ? 0.3 : 0.0,
                              ),
                              colorScheme.primary.withOpacity(
                                imageUrl != null ? 0.8 : 1.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(15.w, 45.h, 20.w, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 22.sp,
                              ),
                              onPressed: () => context.pop(),
                            ),
                            SizedBox(width: 5.w),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "announce.details.badge_title_user".tr(),
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                        ),
                                  ),
                                  Text(
                                    "common.app_name".tr(),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.secondary.withOpacity(
                                        0.9,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colorScheme.secondary,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 26.r,
                                backgroundColor: Colors.white24,
                                child: Icon(
                                  Icons.campaign_rounded,
                                  color: Colors.white,
                                  size: 24.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.all(20.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildDetailCard(
                      context,
                      title: title,
                      description: description,
                      deadline: formattedDeadline,
                      postedDate: postedDate,
                    ),
                    SizedBox(height: 100.h),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required String title,
    required String description,
    required String deadline,
    required String postedDate,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.05),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: context.locale.languageCode == 'ar' ? null : -15,
            left: context.locale.languageCode == 'ar' ? -15 : null,
            top: -15,
            child: Icon(
              Icons.campaign_rounded,
              size: 130.sp,
              color: colorScheme.secondary.withOpacity(0.04),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(25.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Text(
                    "announce.details.opportunity_badge".tr().toUpperCase(),
                    style: TextStyle(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
                SizedBox(height: 25.h),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.black87.withOpacity(0.7),
                    height: 1.7,
                    fontSize: 15.sp,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 30.h),
                  child: Divider(thickness: 0.8),
                ),
                if (deadline.isNotEmpty)
                  _buildInfoRow(
                    context,
                    Icons.timer_outlined,
                    "announce.details.deadline_label".tr(),
                    deadline,
                    Colors.redAccent,
                  ),
                if (deadline.isNotEmpty) SizedBox(height: 20.h),
                if (postedDate.isNotEmpty)
                  _buildInfoRow(
                    context,
                    Icons.calendar_today_rounded,
                    "announce.details.posted_label".tr(),
                    postedDate,
                    Colors.blueGrey,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, size: 20.sp, color: color),
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[500], fontSize: 12.sp),
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
