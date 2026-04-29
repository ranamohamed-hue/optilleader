import 'package:cached_network_image/cached_network_image.dart'; // يُفضل استخدامها لعمل Cache للصورة
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
// import 'edit_announcement_page.dart'; // تأكدي من استيراد صفحة التعديل

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
          // Navigator.push(context, MaterialPageRoute(builder: (context) => EditAnnouncementPage(announcement: announcement)));
        },
        elevation: 4,
        backgroundColor: colorScheme.primary,
        icon: Icon(Icons.edit_note_rounded, color: colorScheme.secondary),
        label: const Text(
          "تعديل الإعلان",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // --- الهيدر الفخم مع الصورة (SliverAppBar) ---
          SliverAppBar(
            expandedHeight: announcement.imageUrl != null
                ? 300.0
                : 160.0, // تكبير الهيدر لو في صورة
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
                  // منطق الحذف هنا
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
                  // 1. عرض الصورة الخلفية لو موجودة
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

                  // 2. طبقة تدرج لوني (Gradient Overlay) عشان النص يبان فوق الصورة
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(
                            announcement.imageUrl != null ? 0.3 : 0.0,
                          ), // تعتيم خفيف فوق
                          colorScheme.primary.withOpacity(
                            announcement.imageUrl != null ? 0.8 : 1.0,
                          ), // الكحلي تحت
                        ],
                      ),
                    ),
                  ),

                  // 3. المحتوى العلوي (زر الرجوع والبروفايل)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 60, 20, 0),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // النص والبروفايل فوق
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
                        // صورة البروفايل بإطار ذهبي
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
                                "ANNOUNCEMENT",
                                style: textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Text(
                                "Aman System Management",
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

          // --- محتوى التفاصيل السفلي ---
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildAnnouncementDetailCard(
                  context,
                  announcement: announcement,
                ),
                const SizedBox(height: 100), // مساحة للـ FAB
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
    final statusColor = announcement.getStatusColor();

    // تنسيق التاريخ
    final formattedDeadline = DateFormat(
      'EEEE, d MMMM yyyy',
    ).format(announcement.deadline);
    final postedDate = DateFormat('d MMM yyyy').format(announcement.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
          // أيقونة خلفية جمالية
          Positioned(
            right: -15,
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
                // Badge الحالة
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
                    announcement.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // العنوان
                Text(
                  announcement.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 18),

                // الوصف
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

                // قسم المعلومات (Info Tiles)
                _buildInfoRow(
                  context,
                  Icons.groups_rounded,
                  "عدد المتقدمين",
                  "${announcement.applicants} شخص",
                  statusColor,
                ),
                const SizedBox(height: 20),
                _buildInfoRow(
                  context,
                  Icons.timer_outlined,
                  "آخر موعد",
                  formattedDeadline,
                  colorScheme.primary,
                ),
                const SizedBox(height: 20),
                _buildInfoRow(
                  context,
                  Icons.calendar_today_rounded,
                  "تاريخ النشر",
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
