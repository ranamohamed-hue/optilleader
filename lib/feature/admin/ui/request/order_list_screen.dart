import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/routing/routes.dart';

class OrdersListScreen extends StatelessWidget {
  const OrdersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryNavy = theme.primaryColor;
    final goldAccent = theme.colorScheme.secondary;
    final bgLight = theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: primaryNavy,
        elevation: 10,
        title: Text(
          'orders.title'.tr(),
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20.sp, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(Routes.admin);
            }
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.h),
          child: Container(color: goldAccent, height: 4.h),
        ),
      ),
      body: Column(
        children: [
          // شريط البحث المربوط بالترجمة
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 5.h),
                ),
              ],
            ),
            child: TextField(
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'orders.search_hint'.tr(),
                hintStyle: theme.textTheme.bodySmall?.copyWith(fontSize: 13.sp),
                prefixIcon: Icon(Icons.search, color: primaryNavy, size: 22.sp),
                filled: true,
                fillColor: bgLight.withOpacity(0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          // قائمة الطلبات
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(15.w),
              children: [
                _buildOrderItem(
                  context,
                  'سارة محمد عبد الرحمن',
                  'orders.status.new'.tr(), // مربوط بالترجمة
                  Colors.blue,
                  '2024/03/15',
                ),
                _buildOrderItem(
                  context,
                  'أحمد علي محمد',
                  'orders.status.review'.tr(), // مربوط بالترجمة
                  Colors.orange,
                  '2024/03/10',
                ),
                _buildOrderItem(
                  context,
                  'منى محمود حسن',
                  'orders.status.approved'.tr(), // مربوط بالترجمة
                  Colors.green,
                  '2024/03/05',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(
    BuildContext context,
    String name,
    String status,
    Color statusColor,
    String date,
  ) {
    final theme = Theme.of(context);
    final goldAccent = theme.colorScheme.secondary;
    final primaryNavy = theme.primaryColor;

    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: goldAccent.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(15.w),
        leading: CircleAvatar(
          backgroundColor: primaryNavy.withOpacity(0.1),
          child: Icon(
            Icons.description_outlined,
            color: primaryNavy,
            size: 20.sp,
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            color: primaryNavy,
            fontWeight: FontWeight.bold,
            fontSize: 15.sp,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 5.h),
          child: Text(
            date, 
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: statusColor.withOpacity(0.5)),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 11.sp,
            ),
          ),
        ),
        onTap: () {
          // تم التعديل لاستخدام GoRouter ليتناسب مع هيكلة مشروعك
          context.push(Routes.fullEmployeeReport); 
        },
      ),
    );
  }
}