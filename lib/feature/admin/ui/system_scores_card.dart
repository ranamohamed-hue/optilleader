import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart'; 
import 'package:optialeader/feature/admin/data/model/nomination_request_model.dart';

class SystemScoresCard extends StatelessWidget {
  final NominationRequestModel request;

  const SystemScoresCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scores = request.scores;
    final details = scores?.itemsDetails ?? [];
    
    final researchPoints = scores?.researchPoints ?? 0.0;
    final conferencePoints = scores?.conferencePoints ?? 0.0;
    final exhibitionPoints = scores?.exhibitionPoints ?? 0.0;
    final coursePoints = scores?.coursePoints ?? 0.0;
    final activityPoints = scores?.activityPoints ?? 0.0;
    final totalPoints = scores?.achievementsTotal ?? 0.0;

    // ✅ تم التعديل هنا
    final String pointUnit = 'nomination_details.system_scores.point_unit'.tr();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: theme.primaryColor.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ====== Header ======
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
            ),
            child: Row(
              children: [
                Icon(Icons.analytics_rounded, color: Colors.white, size: 22.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'nomination_details.system_scores.title'.tr(), // ✅ تم التعديل هنا
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    // ✅ تم إصلاح الخطأ البرمجي هنا (كان ناقص { )
                    '${totalPoints.toStringAsFixed(1)} $pointUnit',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow(
                  icon: Icons.school_rounded,
                  color: Colors.blue,
                  label: 'nomination_details.system_scores.summary.courses'.tr(), // ✅ تم التعديل
                  points: coursePoints,
                  pointUnit: pointUnit,
                ),
                SizedBox(height: 8.h),
                _buildSummaryRow(
                  icon: Icons.groups_rounded,
                  color: Colors.orange,
                  label: 'nomination_details.system_scores.summary.conferences'.tr(), // ✅ تم التعديل
                  points: conferencePoints,
                  pointUnit: pointUnit,
                ),
                SizedBox(height: 8.h),
                _buildSummaryRow(
                  icon: Icons.brush_rounded,
                  color: Colors.deepOrange,
                  label: 'nomination_details.system_scores.summary.exhibitions'.tr(), // ✅ تم التعديل
                  points: exhibitionPoints,
                  pointUnit: pointUnit,
                ),
                SizedBox(height: 8.h),
                _buildSummaryRow(
                  icon: Icons.menu_book_rounded,
                  color: Colors.purple,
                  label: 'nomination_details.system_scores.summary.research'.tr(), // ✅ تم التعديل
                  points: researchPoints,
                  pointUnit: pointUnit,
                ),
                SizedBox(height: 8.h),
                _buildSummaryRow(
                  icon: Icons.assignment_turned_in_rounded,
                  color: Colors.teal,
                  label: 'nomination_details.system_scores.summary.activities'.tr(), // ✅ تم التعديل
                  points: activityPoints,
                  pointUnit: pointUnit,
                ),

                SizedBox(height: 16.h),
                Divider(height: 1, color: Colors.grey.shade300),
                SizedBox(height: 16.h),

                Row(
                  children: [
                    Icon(Icons.list_alt_rounded, color: theme.primaryColor, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'nomination_details.system_scores.details_title'.tr(), // ✅ تم التعديل
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                if (details.isEmpty)
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: Text(
                        'nomination_details.system_scores.no_details'.tr(), // ✅ تم التعديل
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  )
                else
                  ...details.map((item) => _buildItemCard(context, item)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required Color color,
    required String label,
    required double points,
    required String pointUnit,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          Text(
            '${points.toStringAsFixed(1)} $pointUnit',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, Map<String, dynamic> item) {
    final theme = Theme.of(context);
    final title = (item['title'] ?? 'nomination_details.system_scores.no_title'.tr()).toString(); // ✅ تم التعديل
    final type = (item['type'] ?? '').toString();
    final category = (item['category'] ?? '').toString();
    final scope = (item['scope'] ?? '').toString();
    final points = (item['points'] ?? 0.0).toDouble();

    String typeTranslated = 'nomination_details.system_scores.no_title'.tr(); // ✅ تم التعديل
    Color typeColor = Colors.grey;
    IconData typeIcon = Icons.article_rounded;

    switch (type) {
      case 'دورة تدريبية':
        typeColor = Colors.blue;
        typeIcon = Icons.school_rounded;
        typeTranslated = 'nomination_details.system_scores.types.training_course'.tr(); // ✅ تم التعديل
        break;
      case 'مؤتمر':
        typeColor = Colors.orange;
        typeIcon = Icons.groups_rounded;
        typeTranslated = 'nomination_details.system_scores.types.conference'.tr(); // ✅ تم التعديل
        break;
      case 'معرض فني':
      case 'معرض فني (بحث معلق)':
        typeColor = Colors.deepOrange;
        typeIcon = Icons.brush_rounded;
        typeTranslated = 'nomination_details.system_scores.types.art_exhibition'.tr(); // ✅ تم التعديل
        break;
      case 'بحث علمي':
        typeColor = Colors.purple;
        typeIcon = Icons.menu_book_rounded;
        typeTranslated = 'nomination_details.system_scores.types.research_paper'.tr(); // ✅ تم التعديل
        break;
      case 'نشاط تدريسي':
        typeColor = Colors.teal;
        typeIcon = Icons.assignment_turned_in_rounded;
        typeTranslated = 'nomination_details.system_scores.types.teaching_activity'.tr(); // ✅ تم التعديل
        break;
      case 'نشاط بحثي':
        typeColor = Colors.teal;
        typeIcon = Icons.assignment_turned_in_rounded;
        typeTranslated = 'nomination_details.system_scores.types.research_activity'.tr(); // ✅ تم التعديل
        break;
      case 'نشاط مجتمعي':
        typeColor = Colors.teal;
        typeIcon = Icons.assignment_turned_in_rounded;
        typeTranslated = 'nomination_details.system_scores.types.community_activity'.tr(); // ✅ تم التعديل
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: typeColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(typeIcon, color: typeColor, size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '+${points.toStringAsFixed(1)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 14.sp, color: Colors.grey[500]),
                SizedBox(width: 6.w),
                Expanded(
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 4.h,
                    children: [
                      if (type.isNotEmpty)
                        _buildDetailChip('nomination_details.system_scores.chip_labels.type'.tr(), typeTranslated, typeColor), // ✅ تم التعديل
                      if (category.isNotEmpty)
                        _buildDetailChip('nomination_details.system_scores.chip_labels.category'.tr(), category, Colors.teal), // ✅ تم التعديل
                      if (scope.isNotEmpty)
                        _buildDetailChip('nomination_details.system_scores.chip_labels.details'.tr(), scope, Colors.indigo), // ✅ تم التعديل
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 11.sp),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
            TextSpan(
              text: value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}