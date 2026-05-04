import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/routing/routes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // تأكدي من وجود الـ import ده

class UploadFilePage extends StatelessWidget {
  const UploadFilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryDark = theme.colorScheme.primary;
    final accentGold = theme.colorScheme.secondary;
    final backgroundColor = theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryDark,
        elevation: 0,
        toolbarHeight: 70.h, // استخدام h هنا
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20.sp), // استخدام sp هنا
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(Routes.user);
            }
          },
        ),
        title: Text(
          'upload.title'.tr(),
          style: TextStyle(
            // شلت الـ const عشان sp ديناميكي
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp, // استخدام sp
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.h),
          child: Container(color: accentGold, height: 2.h),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w), // استخدام w للـ padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "upload.subtitle".tr(),
              style: TextStyle(
                fontSize: 16.sp, // استخدام sp
                fontWeight: FontWeight.bold,
                color: primaryDark,
              ),
            ),
            SizedBox(height: 20.h),

            GestureDetector(
              onTap: () {
                // هنا هتحطي الـ File Picker لاحقاً
              },
              child: Container(
                width: double.infinity,
                height: 180.h, // استخدام h للارتفاع
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20.r), // r للـ radius
                  border: Border.all(
                    color: accentGold.withOpacity(0.5),
                    width: 2.w,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 50.sp, // sp للأيقونات برضه
                      color: primaryDark,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "upload.click_to_select".tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "upload.file_types".tr(),
                      style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30.h),

            _buildInputField(
              "upload.label_title".tr(),
              "upload.hint_title".tr(),
              primaryDark,
              accentGold,
            ),
            SizedBox(height: 15.h),
            _buildInputField(
              "upload.label_category".tr(),
              "upload.hint_category".tr(),
              primaryDark,
              accentGold,
            ),
            SizedBox(height: 15.h),
            _buildInputField(
              "upload.label_desc".tr(),
              "upload.hint_desc".tr(),
              primaryDark,
              accentGold,
              maxLines: 3,
            ),

            SizedBox(height: 40.h),

            SPrimaryButton(
              text: "upload.btn_upload".tr(),
              color: primaryDark,
              textColor: accentGold,
              onPressed: () {
                // Logic Firebase
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    Color primary,
    Color gold, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primary,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          maxLines: maxLines,
          style: TextStyle(fontSize: 13.sp),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: primary.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: gold, width: 1.5.w),
            ),
          ),
        ),
      ],
    );
  }
}

class SPrimaryButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  const SPrimaryButton({
    super.key,
    required this.text,
    required this.color,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55.h, // استخدام h
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          elevation: 2,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }
}
