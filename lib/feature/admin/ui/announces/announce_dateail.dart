import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';

class AnnouncementDetailsPage extends StatelessWidget {
  final AnnouncementModel announcement;

  const AnnouncementDetailsPage({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // زر التعديل (FAB)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigator.push logic here
        },
        elevation: 4,
        backgroundColor: colorScheme.primary,
        icon: Icon(Icons.edit_note_rounded, color: colorScheme.secondary),
        label: Text(
          "announce.details.edit_button".tr(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: announcement.imageUrl != null ? 300.0 : 160.0,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: colorScheme.primary,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.delete_sweep_outlined,
                  color: Colors.white70,
                ),
                onPressed: () {
                  // حذف الإعلان
                },
              ),
              const SizedBox(width: 10),
            ],
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (announcement.imageUrl != null)
                    CachedNetworkImage(
                      imageUrl: announcement.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.black12),
                      errorWidget: (context, url, error) => Container(
                        color: colorScheme.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: colorScheme.primary,
                          size: 40,
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
                            announcement.imageUrl != null ? 0.3 : 0.0,
                          ),
                          colorScheme.primary.withOpacity(
                            announcement.imageUrl != null ? 0.8 : 1.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 60, 20, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 22,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.secondary,
                              width: 2,
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.white24,
                            child: Icon(
                              Icons.admin_panel_settings,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "announce.details.badge_title".tr(),
                                style: textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Text(
                                "common.app_name".tr(),
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.secondary.withOpacity(0.9),
                                ),
                              ),
                            ],
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
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildAnnouncementDetailCard(
                  context,
                  announcement: announcement,
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementDetailCard(
    BuildContext context, {
    required AnnouncementModel announcement,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = announcement.getStatusColor(context);

    final formattedDeadline = DateFormat(
      'EEEE, d MMMM yyyy',
      context.locale.languageCode,
    ).format(announcement.deadline);
    final postedDate = DateFormat(
      'd MMM yyyy',
      context.locale.languageCode,
    ).format(announcement.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
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
              size: 130,
              color: statusColor.withOpacity(0.04),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    // نستخدم مفتاح الحالة الديناميكي (active, closed, pending)
                    "announce.${announcement.status.toLowerCase()}"
                        .tr()
                        .toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  announcement.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  announcement.description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.black87.withOpacity(0.7),
                    height: 1.7,
                    fontSize: 15,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Divider(thickness: 0.8),
                ),
                _buildInfoRow(
                  context,
                  Icons.groups_rounded,
                  "announce.details.applicants_label".tr(),
                  "${announcement.applicants} ${'announce.details.person_unit'.tr()}",
                  statusColor,
                ),
                const SizedBox(height: 20),
                _buildInfoRow(
                  context,
                  Icons.timer_outlined,
                  "announce.details.deadline_label".tr(),
                  formattedDeadline,
                  colorScheme.primary,
                ),
                const SizedBox(height: 20),
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
