import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/admin/logic/announcement_logic/announcement_cubit.dart';

class EditAnnouncementPage extends StatefulWidget {
  final AnnouncementModel announcement;

  const EditAnnouncementPage({super.key, required this.announcement});

  @override
  State<EditAnnouncementPage> createState() => _EditAnnouncementPageState();
}

class _EditAnnouncementPageState extends State<EditAnnouncementPage> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late TextEditingController _dateController;
  late String _selectedStatus;
  late DateTime _selectedDeadline;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.announcement.title);
    _bodyController = TextEditingController(
      text: widget.announcement.description,
    );
    _selectedDeadline = widget.announcement.deadline;
    _selectedStatus = widget.announcement.status;

    // تهيئة التاريخ بناءً على لغة الجهاز (عربي أو إنجليزي)
    _dateController = TextEditingController(
      text: DateFormat.yMd(
        context.locale.languageCode,
      ).format(_selectedDeadline),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryNavy = const Color(0xFF0A1D37); // الكحلي الملكي
    final accentGold = const Color(0xFFC5A358); // الذهبي
    final softBeige = const Color(0xFFF8F5F0); // خلفية بيج فاتحة جداً

    return Scaffold(
      backgroundColor: softBeige,
      body: CustomScrollView(
        slivers: [
          // AppBar بتصميم دائري وألوان ملكية
          SliverAppBar(
            expandedHeight: 100.0,
            pinned: true,
            backgroundColor: primaryNavy,
            elevation: 8,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                "edit_announcement.title".tr(),
                style: TextStyle(
                  color: accentGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // عنوان الإعلان
                    _buildFieldLabel(
                      "edit_announcement.field_title".tr(),
                      Icons.title_rounded,
                      accentGold,
                      primaryNavy,
                    ),
                    _buildCustomTextField(
                      _titleController,
                      accentGold,
                      softBeige,
                      primaryNavy,
                      hint: "edit_announcement.hint_title".tr(),
                    ),

                    const SizedBox(height: 25),

                    // وصف الإعلان
                    _buildFieldLabel(
                      "edit_announcement.field_desc".tr(),
                      Icons.subject_rounded,
                      accentGold,
                      primaryNavy,
                    ),
                    _buildCustomTextField(
                      _bodyController,
                      accentGold,
                      softBeige,
                      primaryNavy,
                      hint: "edit_announcement.hint_desc".tr(),
                      maxLines: 4,
                    ),

                    const SizedBox(height: 25),

                    // التاريخ والحالة في صف واحد
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel(
                                "edit_announcement.field_date".tr(),
                                Icons.calendar_month_rounded,
                                accentGold,
                                primaryNavy,
                              ),
                              _buildDateField(
                                accentGold,
                                softBeige,
                                primaryNavy,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel(
                                "edit_announcement.field_status".tr(),
                                Icons.info_outline_rounded,
                                accentGold,
                                primaryNavy,
                              ),
                              _buildStatusDropdown(
                                accentGold,
                                softBeige,
                                primaryNavy,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // أزرار التحكم
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "common.cancel".tr(),
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () => _handleUpdate(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryNavy,
                              foregroundColor: accentGold,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 4,
                            ),
                            child: Text(
                              "edit_announcement.save_button".tr(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widgets المساعدة مع دعم الـ Localization ---

  Widget _buildFieldLabel(String label, IconData icon, Color gold, Color navy) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4, right: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: gold),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: navy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTextField(
    TextEditingController controller,
    Color gold,
    Color beige,
    Color navy, {
    int maxLines = 1,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: navy, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        filled: true,
        fillColor: beige.withOpacity(0.5),
        contentPadding: const EdgeInsets.all(16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: gold, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDateField(Color gold, Color beige, Color navy) {
    return InkWell(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDeadline,
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          setState(() {
            _selectedDeadline = pickedDate;
            _dateController.text = DateFormat.yMd(
              context.locale.languageCode,
            ).format(pickedDate);
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: beige.withOpacity(0.5),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _dateController.text,
              style: TextStyle(fontSize: 13, color: navy),
            ),
            Icon(Icons.calendar_today_rounded, size: 16, color: gold),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(Color gold, Color beige, Color navy) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: beige.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: gold),
          style: TextStyle(
            color: navy,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          onChanged: (val) => setState(() => _selectedStatus = val!),
          items: ['Active', 'Pending', 'Closed']
              .map((v) => DropdownMenuItem(value: v, child: Text(v.tr())))
              .toList(),
        ),
      ),
    );
  }

  void _handleUpdate(BuildContext context) {
    final updatedModel = widget.announcement.copyWith(
      title: _titleController.text,
      description: _bodyController.text,
      status: _selectedStatus,
      deadline: _selectedDeadline,
    );

    context.read<AnnouncementCubit>().updateAnnouncement(updatedModel);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("edit_announcement.success_msg".tr()),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
