import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AnnouncementDetailsDoctorPage extends StatefulWidget {
  final String announcementId;

  const AnnouncementDetailsDoctorPage({super.key, required this.announcementId});

  @override
  State<AnnouncementDetailsDoctorPage> createState() => _AnnouncementDetailsDoctorPageState();
}

class _AnnouncementDetailsDoctorPageState extends State<AnnouncementDetailsDoctorPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('تفاصيل الإعلان'),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('announcements').doc(widget.announcementId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: colorScheme.secondary));
          }

          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60.sp, color: Colors.grey),
                  SizedBox(height: 10.h),
                  const Text('عذراً، لم يتم العثور على هذا الإعلان'),
                ],
              ),
            );
          }

          // استخراج البيانات
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final String title = data['title'] ?? 'بدون عنوان';
          final String description = data['description'] ?? 'لا يوجد تفاصيل';
          final String? imageUrl = data['imageUrl'];
          final Timestamp? timestamp = data['createdAt'];
          final String date = timestamp != null ? "${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}" : '';

          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // صورة الإعلان (لو موجودة)
                if (imageUrl != null && imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.r),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(height: 200.h, color: Colors.grey.shade200),
                      errorWidget: (_, __, ___) => Icon(Icons.broken_image, size: 80.sp, color: Colors.grey),
                    ),
                  ),
                
                SizedBox(height: 20.h),
                
                // التاريخ
                if (date.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16.sp, color: colorScheme.primary),
                      SizedBox(width: 8.w),
                      Text(date, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.primary)),
                    ],
                  ),
                
                SizedBox(height: 15.h),
                
                // العنوان
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                
                SizedBox(height: 15.h),
                
                // التفاصيل
                Container(
                  padding: EdgeInsets.all(15.w),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
                  ),
                  child: Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.8,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}