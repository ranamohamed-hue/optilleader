import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart'; 
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/admin/logic/announcement_logic/announcement_cubit.dart';
import 'package:intl/intl.dart'; 
class EditAnnouncementPage extends StatefulWidget {
  final AnnouncementModel?
  announcement; // ✅ Nullable عشان نستخدمها في الإضافة والتعديل

  const EditAnnouncementPage({super.key, this.announcement});

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
    // لو فيه announcement يبقى تعديل، لو مفيش يبقى إضافة جديدة
    _titleController = TextEditingController(
      text: widget.announcement?.title ?? '',
    );
    _bodyController = TextEditingController(
      text: widget.announcement?.description ?? '',
    );
    _selectedDeadline = widget.announcement?.deadline ?? DateTime.now();
    _selectedStatus = widget.announcement?.status ?? 'Active';

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
    // ✅ شيلنا الألوان الثابتة وخديناها من الثيم
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100.0,
            pinned: true,
            backgroundColor: colorScheme.primary,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => context.pop(),
            ), // ✅ GoRouter
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                "edit_announcement.title".tr(),
                style: TextStyle(
                  color: colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
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
                  color: colorScheme.surface, // ✅ من الثيم
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
                    _buildFieldLabel(
                      "edit_announcement.field_title".tr(),
                      Icons.title_rounded,
                      colorScheme,
                    ),
                    _buildCustomTextField(
                      _titleController,
                      colorScheme,
                      hint: "edit_announcement.hint_title".tr(),
                    ),
                    const SizedBox(height: 25),
                    _buildFieldLabel(
                      "edit_announcement.field_desc".tr(),
                      Icons.subject_rounded,
                      colorScheme,
                    ),
                    _buildCustomTextField(
                      _bodyController, // ✅ الصح: كنترولر الوصف
                      colorScheme,
                      hint: "edit_announcement.hint_desc".tr(),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel(
                                "edit_announcement.field_date".tr(),
                                Icons.calendar_month_rounded,
                                colorScheme,
                              ),
                              _buildDateField(colorScheme),
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
                                colorScheme,
                              ),
                              _buildStatusDropdown(colorScheme),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => context.pop(),
                            child: Text(
                              "common.cancel".tr(),
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ),
                        ), // ✅ GoRouter
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () => _handleUpdate(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              "edit_announcement.save_button".tr(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
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

  Widget _buildFieldLabel(
    String label,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4, right: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.secondary),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTextField(
    TextEditingController controller,
    ColorScheme colorScheme, {
    int maxLines = 1,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: colorScheme.primary),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(
          0.3,
        ), // ✅ من الثيم
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: colorScheme.secondary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDateField(ColorScheme colorScheme) {
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
          color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _dateController.text,
              style: TextStyle(fontSize: 13, color: colorScheme.primary),
            ),
            Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: colorScheme.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: colorScheme.secondary,
          ),
          style: TextStyle(
            color: colorScheme.primary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          onChanged: (val) => setState(() => _selectedStatus = val!),
          // ✅ الـ Status بيتحول لمفتاح ترجمة تلقائياً
          items: AnnouncementModel.statusList
              .map(
                (v) =>
                    DropdownMenuItem(value: v, child: Text("announce.$v".tr())),
              )
              .toList(),
        ),
      ),
    );
  }

  void _handleUpdate(BuildContext context) {
    // لو التعديل
    if (widget.announcement != null) {
      final updatedModel = widget.announcement!.copyWith(
        title: _titleController.text,
        description: _bodyController.text,
        status: _selectedStatus,
        deadline: _selectedDeadline,
      );
      context.read<AnnouncementCubit>().updateAnnouncement(updatedModel);
    } else {
      // لو إضافة جديدة
      final newAnnouncement = AnnouncementModel(
        title: _titleController.text,
        description: _bodyController.text,
        status: _selectedStatus,
        deadline: _selectedDeadline,
        createdAt: DateTime.now(),
      );
      context.read<AnnouncementCubit>().addAnnouncement(newAnnouncement);
    }

    context.pop(); // ✅ GoRouter
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("edit_announcement.success_msg".tr()),
        backgroundColor: Colors.green[700],
      ),
    );
  }
}
