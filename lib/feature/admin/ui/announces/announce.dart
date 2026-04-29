import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/admin/logic/announcement_logic/announcement_cubit.dart';
import 'package:optialeader/feature/admin/logic/announcement_logic/announcement_state.dart';
import 'package:optialeader/feature/admin/ui/announces/announce_dateail.dart';
import '../../data/model/announcement_model.dart';

class AnnouncementsPage extends StatelessWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // الـ BlocBuilder لمراقبة الـ States اللي بعتيها في الملف
      body: BlocBuilder<AnnouncementCubit, AnnouncementState>(
        builder: (context, state) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. الهيدر (الـ SliverAppBar)
              _buildHeader(context, colorScheme, theme),

              // 2. المحتوى المتغير بناءً على حالة الـ Bloc
              ..._buildBodyBasedOnState(state, theme),
            ],
          );
        },
      ),
      floatingActionButton: _buildFAB(context, colorScheme),
    );
  }

  // دالة توزيع الحالات (تطابق ملف الـ State بتاعك بالظبط)
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
        return [_buildEmptyState("لا توجد إعلانات حالياً")];
      }
      return [_buildAnnouncementsList(state.announcements)];
    }

    if (state is AnnouncementError) {
      return [_buildErrorState(state.message)];
    }

    if (state is AnnouncementActionSuccess) {
      return [
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 60,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    // الحالة الابتدائية (Initial)
    return [
      const SliverFillRemaining(
        child: Center(child: Text("جاري تحضير البيانات...")),
      ),
    ];
  }

  // بناء الهيدر بلمسة "Aman App" الملكية
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
              colors: [
                colorScheme.primary,
                colorScheme.primary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "الإعلانات",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "تابع آخر أخبار وتحديثات المدرسة",
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

  // بناء القائمة باستخدام الـ SliverList
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

  // كارت الإعلان الفردي
  Widget _buildAnnouncementCard(
    BuildContext context,
    AnnouncementModel announcement,
  ) {
    final theme = Theme.of(context);
    final statusColor = announcement.getStatusColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AnnouncementDetailsPage(announcement: announcement),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
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
                    const Icon(
                      Icons.arrow_forward_ios,
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
                    height: 1.4,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(thickness: 0.6),
                ),
                Row(
                  children: [
                    Icon(Icons.group_outlined, size: 18, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      "${announcement.applicants} متقدم",
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
                        announcement.status,
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
        ),
      ),
    );
  }

  // ويدجت الحالة الفارغة
  Widget _buildEmptyState(String msg) {
    return SliverFillRemaining(
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
  }

  // ويدجت حالة الخطأ
  Widget _buildErrorState(String message) {
    return SliverFillRemaining(
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
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // زر الإضافة (FAB)
  Widget _buildFAB(BuildContext context, ColorScheme colorScheme) {
    return FloatingActionButton.extended(
      onPressed: () {
        // سيتم الربط بصفحة الإضافة لاحقاً
      },
      backgroundColor: colorScheme.primary,
      icon: Icon(Icons.add_rounded, color: colorScheme.secondary),
      label: const Text(
        "إضافة إعلان",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
