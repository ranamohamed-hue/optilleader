import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/routing/routes.dart';

class DigitalArchivePage extends StatelessWidget {
  const DigitalArchivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          elevation: 0,
          toolbarHeight: 80.h,
          automaticallyImplyLeading: false,
          // زر الرجوع الموحد
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
              _buildAppBarProfile(colorScheme),
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
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
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
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15.w,
                  mainAxisSpacing: 15.h,
                  childAspectRatio: 0.85,
                  children: [
                    _buildFolderCard(
                      context,
                      "archive.folders.certificates".tr(),
                      "archive.folders.certificates_sub".tr(),
                      Colors.teal.shade300,
                      3,
                    ),
                    _buildFolderCard(
                      context,
                      "archive.folders.id".tr(),
                      "archive.folders.id_sub".tr(),
                      Colors.amber.shade400,
                      4,
                    ),
                    _buildFolderCard(
                      context,
                      "archive.folders.decisions".tr(),
                      "archive.folders.decisions_sub".tr(),
                      Colors.blue.shade300,
                      5,
                    ),
                    _buildFolderCard(
                      context,
                      "archive.folders.misc".tr(),
                      "archive.folders.misc_sub".tr(),
                      Colors.purple.shade300,
                      3,
                      badgeCount: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // هنا يتم إضافة منطق رفع ملف جديد
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
  }

  Widget _buildAppBarProfile(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colorScheme.secondary, width: 1.5),
      ),
      child: CircleAvatar(
        radius: 18.r,
        backgroundColor: colorScheme.secondary.withOpacity(0.2),
        child: Icon(Icons.person, color: Colors.white, size: 18.sp),
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
          onTap: () {
            // منطق البحث
          },
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

  Widget _buildFolderCard(
    BuildContext context,
    String title,
    String subtitle,
    Color folderColor,
    int filesCount, {
    int badgeCount = 0,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        // الانتقال لفتح المجلد وعرض الملفات
      },
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
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Icon(
                      Icons.folder_rounded,
                      size: 65.sp,
                      color: folderColor.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                      color: colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey, fontSize: 10.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 12.sp,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        "$filesCount",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (badgeCount > 0)
              PositionedDirectional(
                top: 10.h,
                end: 10.w,
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "$badgeCount",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
