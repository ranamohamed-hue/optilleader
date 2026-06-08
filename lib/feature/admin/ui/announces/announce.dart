import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/admin/logic/announcement_logic/announcement_cubit.dart';
import 'package:optialeader/feature/admin/logic/announcement_logic/announcement_state.dart';

class AnnouncementsPage extends StatelessWidget {
  final VoidCallback? onBack; // ✅ استقبال دالة الرجوع

  const AnnouncementsPage({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: BlocBuilder<AnnouncementCubit, AnnouncementState>(
        builder: (context, state) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(context, colorScheme, theme),
              ..._buildBodyBasedOnState(state, theme),
            ],
          );
        },
      ),
      floatingActionButton: _buildFAB(context, colorScheme),
    );
  }

  List<Widget> _buildBodyBasedOnState(
    AnnouncementState state,
    ThemeData theme,
  ) {
    if (state is AnnouncementLoading) {
      return [
        const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (state is AnnouncementLoaded) {
      if (state.announcements.isEmpty) {
        return [_buildEmptyState("announce.no_data".tr())];
      }
      return [_buildAnnouncementsList(state.announcements)];
    }
    if (state is AnnouncementError) {
      return [_buildErrorState(state.message)];
    }
    return [
      SliverFillRemaining(
        child: Center(child: Text("announce.preparing".tr())),
      ),
    ];
  }

  Widget _buildHeader(
    BuildContext context,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return SliverAppBar(
      expandedHeight: 130.0,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: colorScheme.primary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.primaryContainer],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                  // ✅ لو الدالة موجودة (جوا الـ Dashboard) يرجع للرئيسية، غير كده يعمل Pop عادي
                  onPressed: () {
                    if (onBack != null) {
                      onBack!();
                    } else {
                      context.pop();
                    }
                  },
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "announce.title".tr(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "announce.subtitle".tr(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.secondary.withOpacity(0.9),
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
    );
  }

  Widget _buildAnnouncementsList(List<AnnouncementModel> announcements) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) =>
              _buildAnnouncementCard(context, announcements[index]),
          childCount: announcements.length,
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(
    BuildContext context,
    AnnouncementModel announcement,
  ) {
    final theme = Theme.of(context);
    final statusColor = announcement.getStatusColor(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () =>
              context.push('/admin/announcementDetails', extra: announcement),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              announcement.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          Icon(
                            context.locale.languageCode == 'ar'
                                ? Icons.arrow_back_ios
                                : Icons.arrow_forward_ios,
                            size: 12,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        announcement.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(thickness: 0.6),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.group_outlined,
                            size: 18,
                            color: statusColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "${announcement.applicants} ${'announce.details.person_unit'.tr()}",
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "announce.${announcement.status.toLowerCase()}"
                                  .tr(),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (announcement.imageUrl != null &&
                    announcement.imageUrl!.isNotEmpty) ...[
                  const SizedBox(width: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: announcement.imageUrl!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Colors.grey[200],
                        width: 70,
                        height: 70,
                      ),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.broken_image, size: 40),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String msg) => SliverFillRemaining(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(msg, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    ),
  );

  Widget _buildErrorState(String errorCode) => SliverFillRemaining(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 60,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Text(
              errorCode.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildFAB(BuildContext context, ColorScheme colorScheme) {
    return FloatingActionButton.extended(
      onPressed: () => context.push('/admin/editAnnountmentPage'),
      backgroundColor: colorScheme.primary,
      icon: Icon(Icons.add_rounded, color: colorScheme.secondary),
      label: Text(
        "announce.add_button".tr(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
