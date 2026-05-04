import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/routing/routes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; 

class EvaluationScreen extends StatelessWidget {
  const EvaluationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
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
              context.go(Routes.judge);
            }
          },
        ),
        title: Text(
          'تقييم المتقدم',
          style: textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            fontFamily: 'Tajawal',
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.h),
          child: Container(color: colorScheme.secondary, height: 2.h),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 1. كارت تعريف المتقدم
            _buildApplicantCard(colorScheme),

            // 2. أقسام التقييم
            _buildEvaluationSection(
              context,
              '1. السمات الشخصية والمظهر (الدرجة القصوى: 15)',
              [
                _buildCriterionRow('المظهر العام والهندام', '5', '3'),
                _buildCriterionRow('الثقة بالنفس ومواجهة الجمهور', '5', '5'),
                _buildCriterionRow('الاتزان وحسن التصرف', '5', '2'),
              ],
              '10 / 15',
            ),

            _buildExpandableSection(
              context,
              '2. الكفاءة العلمية والمهنية (الدرجة القصوى: 40)',
            ),
            _buildExpandableSection(
              context,
              '3. مهارات التواصل والعرض (الدرجة القصوى: 25)',
            ),
            _buildExpandableSection(
              context,
              '4. القيادة وتطوير الإدارة (الدرجة القصوى: 20)',
            ),

            // 3. المجموع الكلي
            _buildTotalScore(colorScheme),

            // 4. الملاحظات
            _buildNotesField(colorScheme),

            // 5. الأزرار
            _buildActionButtons(context, colorScheme),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicantCard(ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
        border: Border.all(color: colorScheme.secondary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 35.r,
            backgroundColor: colorScheme.secondary.withOpacity(0.1),
            child: Icon(
              Icons.person,
              size: 45.sp,
              color: colorScheme.secondary,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'د. أحمد منصور',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
              fontFamily: 'Tajawal',
            ),
          ),
          Text(
            'قسم علوم الحاسب - كلية الهندسة',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: colorScheme.secondary.withOpacity(0.2)),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
          ),
        ),
        trailing: Icon(Icons.keyboard_arrow_down, size: 24.sp),
        children: [
          Padding(
            padding: EdgeInsets.all(15.w),
            child: Text(
              "محتوى التقييم يظهر هنا...",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalScore(ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      child: Container(
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                '10 / 100',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ),
            Text(
              'المجموع الكلي :',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: Colors.white,
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField(ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'ملاحظات وتوصيات إضافية',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
              fontSize: 14.sp,
              fontFamily: 'Tajawal',
            ),
          ),
          SizedBox(height: 10.h),
          TextField(
            maxLines: 3,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 13.sp),
            decoration: InputDecoration(
              hintText: 'اكتب ملاحظاتك هنا...',
              hintStyle: TextStyle(fontSize: 12.sp),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.r),
                borderSide: BorderSide(
                  color: colorScheme.secondary.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 15.h),
              ),
              child: Text(
                'اعتماد التقييم',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 15.h),
              ),
              child: Text(
                'حفظ كمسودة',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationSection(
    BuildContext context,
    String title,
    List<Widget> criteria,
    String subTotal,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: colorScheme.secondary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
                fontSize: 13.sp,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
          ...criteria,
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subTotal,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  'المجموع الفرعي :',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriterionRow(
    String label,
    String maxScore,
    String currentScore,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      child: Row(
        children: [
          Container(
            width: 45.w,
            height: 35.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Text(
                currentScore,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  label,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                  ),
                ),
                Text(
                  'الدرجة القصوى: $maxScore',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
