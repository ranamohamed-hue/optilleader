import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/routing/routes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart'; // ✅ [إضافة] لاختيار الملفات
import 'package:flutter_bloc/flutter_bloc.dart'; // ✅ [إضافة] عشان نكلم الكيوبت
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_cubit.dart';

class UploadFilePage extends StatefulWidget {
  final String doctorUid; // ✅ [إضافة] لازم نبعت الـ uid للصفحة دي

  const UploadFilePage({super.key, required this.doctorUid});

  @override
  State<UploadFilePage> createState() => _UploadFilePageState();
}

class _UploadFilePageState extends State<UploadFilePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String? _selectedCategory;

  // ✅ [إضافة] متغيرات الملف اللي اترفع
  File? _pickedFile;
  String? _pickedFileName;

  final List<String> _categories = [
    'archive.folders.certificates',
    'archive.folders.id',
    'archive.folders.decisions',
    'archive.folders.misc',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // ✅ [إضافة] دالة اختيار الملف من الجهاز
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _pickedFile = File(result.files.single.path!);
        _pickedFileName = result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryDark = theme.colorScheme.primary;
    final accentGold = theme.colorScheme.secondary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryDark,
        elevation: 0,
        toolbarHeight: 70.h,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20.sp,
            color: Colors.white,
          ),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.user),
        ),
        title: Text(
          'upload.title'.tr(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.h),
          child: Container(color: accentGold, height: 2.h),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "upload.subtitle".tr(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: primaryDark,
              ),
            ),
            SizedBox(height: 30.h),

            // حقل العنوان
            _buildInputField(
              label: "upload.label_title".tr(),
              hint: "upload.hint_title".tr(),
              controller: _titleController,
              primary: primaryDark,
              gold: accentGold,
            ),
            SizedBox(height: 15.h),

            // اختيار التصنيف (Dropdown)
            _buildCategoryDropdown(primaryDark, accentGold),
            SizedBox(height: 15.h),

            // حقل الوصف
            _buildInputField(
              label: "upload.label_desc".tr(),
              hint: "upload.hint_desc".tr(),
              controller: _descController,
              primary: primaryDark,
              gold: accentGold,
              maxLines: 3,
            ),
            
            SizedBox(height: 25.h),

            // ✅ [إضافة] منطقة اختيار وعرض الملف
            _buildFilePickerArea(primaryDark, accentGold),
            
            SizedBox(height: 40.h),

            // ✅ [تعديل] زر الرفع مربوط بالكيوبت
            SPrimaryButton(
              text: "upload.btn_upload".tr(),
              color: primaryDark,
              textColor: accentGold,
              onPressed: () {
                // 1. التأكد إن المستخدم اختار ملف وكتب عنوان
                if (_pickedFile == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("الرجاء اختيار ملف أولاً")),
                  );
                  return;
                }
                if (_titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("الرجاء كتابة عنوان الملف")),
                  );
                  return;
                }

                // 2. استدعاء دالة الرفع من الكيوبت
                context.read<DoctorDataCubit>().uploadArchiveFile(
                  uid: widget.doctorUid,
                  file: _pickedFile!,
                  title: _titleController.text,
                  description: _descController.text,
                  category: _selectedCategory ?? 'archive.folders.misc',
                );

                // 3. الرجوع لصفحة الأرشيف بعد الرفع
                if (context.canPop()) {
                  context.pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ✅ [إضافة] ويدجت منطقة اختيار الملف
  Widget _buildFilePickerArea(Color primary, Color gold) {
    return InkWell(
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: _pickedFile != null ? gold : primary.withOpacity(0.3),
            width: 1.5.w,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _pickedFile != null ? Icons.check_circle_outline : Icons.cloud_upload_outlined,
              color: _pickedFile != null ? Colors.green : primary,
              size: 40.sp,
            ),
            SizedBox(height: 10.h),
            Text(
              _pickedFileName ?? "upload.hint_file".tr(), // لو مش عامل الترجمة دي، اكتب بدلها "اضغط لاختيار ملف"
              style: TextStyle(
                color: _pickedFile != null ? primary : Colors.grey,
                fontSize: 13.sp,
                fontWeight: _pickedFile != null ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(Color primary, Color gold) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "upload.label_category".tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primary,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          style: TextStyle(fontSize: 13.sp, color: Colors.black),
          decoration: InputDecoration(
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
          value: _selectedCategory,
          hint: Text(
            "upload.hint_category".tr(),
            style: TextStyle(fontSize: 13.sp),
          ),
          items: _categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category.tr()),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required Color primary,
    required Color gold,
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
          controller: controller,
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
      height: 55.h,
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