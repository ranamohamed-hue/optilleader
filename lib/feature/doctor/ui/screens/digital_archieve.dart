import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ لسه محتاجينها عشان نفتح الملفات

import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_state.dart';

class DigitalArchivePage extends StatelessWidget {
  const DigitalArchivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BlocBuilder<DoctorDataCubit, DoctorDataState>(
      builder: (context, state) {
        DoctorProfileModel? doctor;
        if (state is DoctorLoaded) {
          doctor = state.doctor;
        }

        // ⚠️ افتراضية: لستة الملفات اللي الدكتور رفعها (لازم تربطها بحقل في الموديل بعدين)
        final List<Map<String, String>> archivedFiles = [];

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: colorScheme.primary,
              elevation: 0,
              toolbarHeight: 80.h,
              automaticallyImplyLeading: false,
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
              title: Row(
                children: [
                  _buildAppBarProfile(colorScheme, doctor?.profileImage),
                  SizedBox(width: 12.w),
                  Text(
                    'archive.title'.tr(),
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
              bottom: TabBar(
                indicatorColor: colorScheme.secondary,
                indicatorWeight: 3,
                labelColor: colorScheme.secondary,
                unselectedLabelColor: Colors.white70,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
                tabs: [
                  Tab(text: "archive.tabs.research".tr()),
                  Tab(text: "archive.tabs.conferences".tr()),
                  Tab(text: "archive.tabs.others".tr()),
                ],
              ),
            ),
            body: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  _buildSearchAndSortBar(colorScheme),
                  SizedBox(height: 20.h),
                  Expanded(
                    child: archivedFiles.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.folder_open,
                                  size: 60.sp,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  "archive.no_files".tr(),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 15.w,
                                  mainAxisSpacing: 15.h,
                                  childAspectRatio: 0.85,
                                ),
                            itemCount: archivedFiles.length,
                            itemBuilder: (context, index) {
                              final file = archivedFiles[index];
                              return _buildFileCard(context, file);
                            },
                          ),
                  ),
                ],
              ),
            ),
                      // ✅ [تعديل] ربط الزرار بصفحة رفع الملفات وبعت الـ uid
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (doctor?.uid != null) {
                  context.push('uploadFiles?uid=${doctor!.uid}');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("حدث خطأ، لا يوجد معرف للمستخدم")),
                  );
                }
              },
              backgroundColor: colorScheme.secondary,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Icon(Icons.add, size: 28.sp, color: colorScheme.primary),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBarProfile(ColorScheme colorScheme, String? imageUrl) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colorScheme.secondary, width: 1.5),
      ),
      child: CircleAvatar(
        radius: 18.r,
        backgroundColor: colorScheme.secondary.withOpacity(0.2),
        backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
            ? CachedNetworkImageProvider(imageUrl)
            : null,
        child: (imageUrl == null || imageUrl.isEmpty)
            ? Icon(Icons.person, color: Colors.white, size: 18.sp)
            : null,
      ),
    );
  }

  Widget _buildSearchAndSortBar(ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(Icons.sort_rounded, color: colorScheme.primary, size: 22.sp),
        SizedBox(width: 10.w),
        Text(
          "archive.sort_by_date".tr(),
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search, color: colorScheme.primary, size: 20.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildFileCard(BuildContext context, Map<String, String> file) {
    final colorScheme = Theme.of(context).colorScheme;
    String fileName = file['name'] ?? 'Unknown File';
    String fileUrl = file['url'] ?? '';
    String fileType = file['type'] ?? 'pdf';

    IconData fileIcon = Icons.picture_as_pdf;
    Color iconColor = Colors.red.shade400;
    if (['jpg', 'png', 'jpeg'].contains(fileType.toLowerCase())) {
      fileIcon = Icons.image_outlined;
      iconColor = Colors.blue.shade400;
    } else if (['doc', 'docx'].contains(fileType.toLowerCase())) {
      fileIcon = Icons.description_outlined;
      iconColor = Colors.blue.shade700;
    }

    return InkWell(
      onTap: () => _openFile(fileUrl),
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: colorScheme.primary.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(
                  fileIcon,
                  size: 65.sp,
                  color: iconColor.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                fileName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                fileType.toUpperCase(),
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  Icons.download_rounded,
                  size: 18.sp,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ دالة فتح الملف هتفضل موجودة عشان دي مهمة عرض (Viewing) مش رفع
  Future<void> _openFile(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $url");
    }
  }
}
