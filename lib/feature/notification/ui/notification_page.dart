import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:optialeader/core/theming/app_color.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';
import 'package:optialeader/feature/notification/logic/app_notification_cubit.dart';
import 'package:optialeader/feature/notification/logic/app_notification_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        if (state is NotificationLoading) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.secondary),
          );
        }

        if (state is NotificationError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Text(
                state.message, // الرسالة هتيجي مترجمة من الـ Cubit
                style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (state is NotificationLoaded) {
          if (state.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined, 
                    size: 80.sp, 
                    color: Colors.grey.shade400
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'notifications.empty_state'.tr(), // ✅ مربوط بالترجمة
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(12.w),
            itemCount: state.notifications.length,
            itemBuilder: (context, index) {
              final notification = state.notifications[index];
              return _buildNotificationCard(context, notification);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildNotificationCard(BuildContext context, AppNotificationModel notification) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: notification.isRead ? 0 : 2,
      margin: EdgeInsets.only(bottom: 10.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      color: notification.isRead 
          ? colorScheme.surface 
          : colorScheme.primaryContainer.withOpacity(0.1),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getColorForType(notification.type).withOpacity(0.1),
          child: Icon(
            _getIconForType(notification.type),
            color: _getColorForType(notification.type),
          ),
        ),
        title: Text(
          notification.title, // العنوان هتيجي مترجم من الـ Cubit/Firestore
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Text(
          notification.message, // الرسالة هتيجي مترجمة من الـ Cubit/Firestore
          style: theme.textTheme.bodySmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          _formatTimestamp(notification.timestamp), 
          style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
        ),
        onTap: () {
          if (!notification.isRead) {
             context.read<NotificationCubit>().markAsRead(notification.id);
          }
          // ⏳ [لاحقاً هنعمل تنقل للصفحة المتعلقة بالإشعار]
        },
      ),
    );
  }

  // ✅ دالة لتغيير الأيقونة بناءً على نوع الإشعار
  IconData _getIconForType(NotificationType type) {
    switch (type) {
      // أدمن القاعدة
      case NotificationType.userLogin: return Icons.login;
      case NotificationType.userLogout: return Icons.logout;
      case NotificationType.profileDataUpdated: return Icons.edit_note;
      case NotificationType.accountSuspended: return Icons.block;
      // أدمن عادي
      case NotificationType.welcomeAdmin: return Icons.waving_hand;
      case NotificationType.announcementCreated: return Icons.campaign;
      case NotificationType.announcementExpired: return Icons.notifications_off_outlined;
      case NotificationType.newDoctorRequest: return Icons.add_task;
      case NotificationType.judgeRequestCompleted: return Icons.gavel;
      // دكتور
      case NotificationType.welcomeDoctor: return Icons.waving_hand;
      case NotificationType.newCompetition: return Icons.emoji_events_outlined;
      case NotificationType.competitionResult: return Icons.bar_chart;
      case NotificationType.requestStatusUpdate: return Icons.receipt_long;
      // محكم
      case NotificationType.welcomeJudge: return Icons.waving_hand;
      case NotificationType.newArbitrationRequest: return Icons.assignment_ind;
      
      case NotificationType.general: return Icons.info_outline;
    }
  }

  // ✅ دالة لتغيير اللون بناءً على نوع الإشعار
  Color _getColorForType(NotificationType type) {
    switch (type) {
      // أدمن القاعدة
      case NotificationType.userLogin: return Colors.green;
      case NotificationType.userLogout: return Colors.blueGrey;
      case NotificationType.profileDataUpdated: return Colors.indigo;
      case NotificationType.accountSuspended: return Colors.red;
      // أدمن عادي
      case NotificationType.welcomeAdmin: return Colors.teal;
      case NotificationType.announcementCreated: return Colors.blue;
      case NotificationType.announcementExpired: return Colors.orange;
      case NotificationType.newDoctorRequest: return Colors.lightBlue;
      case NotificationType.judgeRequestCompleted: return AppColors.darkGold;
      // دكتور
      case NotificationType.welcomeDoctor: return Colors.teal;
      case NotificationType.newCompetition: return Colors.purple;
      case NotificationType.competitionResult: return Colors.green;
      case NotificationType.requestStatusUpdate: return Colors.deepOrange;
      // محكم
      case NotificationType.welcomeJudge: return Colors.teal;
      case NotificationType.newArbitrationRequest: return AppColors.darkGold;
      
      case NotificationType.general: return Colors.grey;
    }
  }

  // ✅ دالة لتنسيق الوقت
  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    String hour = date.hour.toString().padLeft(2, '0');
    String minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}