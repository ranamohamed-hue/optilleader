import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/admin/logic/announcement_logic/announcement_cubit.dart';
import 'package:intl/intl.dart';

class EditAnnouncementPage extends StatefulWidget {
  final AnnouncementModel? announcement;

  const EditAnnouncementPage({super.key, this.announcement});

  @override
  State<EditAnnouncementPage> createState() => _EditAnnouncementPageState();
}

class _EditAnnouncementPageState extends State<EditAnnouncementPage> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late TextEditingController _dateController;
  late String _selectedStatus;
  late String _selectedTargetRole;
  late DateTime _selectedDeadline;

  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  String? _selectedCollegeId;
  String? _selectedCollegeName;
  String? _selectedDepartmentId;
  String? _selectedDepartmentName;

  // ملاحظة: البيانات هنا ثابتة للعرض، في التطبيق الفعلي يجب جلبها من الـ API
  final List<Map<String, String>> _colleges = [
    {'id': 'col_01', 'name': 'كلية الهندسة'},
    {'id': 'col_02', 'name': 'كلية الطب'},
    {'id': 'col_03', 'name': 'كلية الحاسب الآلي'},
  ];

  final List<Map<String, String>> _departments = [
    {'id': 'dep_01', 'name': 'قسم الحاسب', 'collegeId': 'col_01'},
    {'id': 'dep_02', 'name': 'قسم المدني', 'collegeId': 'col_01'},
    {'id': 'dep_03', 'name': 'قسم الكهرباء', 'collegeId': 'col_01'},
    {'id': 'dep_04', 'name': 'قسم الجراحة', 'collegeId': 'col_02'},
    {'id': 'dep_05', 'name': 'قسم الباطنة', 'collegeId': 'col_02'},
    {'id': 'dep_06', 'name': 'قسم علوم الحاسب', 'collegeId': 'col_03'},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.announcement?.title ?? '');
    _bodyController = TextEditingController(text: widget.announcement?.description ?? '');
    _selectedDeadline = widget.announcement?.deadline ?? DateTime.now();
    _selectedStatus = widget.announcement?.status ?? 'Active';
    _selectedTargetRole = widget.announcement?.targetRole ?? 'general';
    _dateController = TextEditingController();

    _selectedCollegeId = widget.announcement?.collegeId;
    _selectedCollegeName = widget.announcement?.collegeName;
    _selectedDepartmentId = widget.announcement?.departmentId;
    _selectedDepartmentName = widget.announcement?.departmentName;

    // حماية من Crash إذا لم يكن المعرف موجوداً في القائمة الثابتة
    if (_selectedCollegeId != null && !_colleges.any((c) => c['id'] == _selectedCollegeId)) {
      _colleges.add({'id': _selectedCollegeId!, 'name': _selectedCollegeName ?? ''});
    }
    if (_selectedDepartmentId != null && !_departments.any((d) => d['id'] == _selectedDepartmentId)) {
      _departments.add({'id': _selectedDepartmentId!, 'name': _selectedDepartmentName ?? '', 'collegeId': _selectedCollegeId ?? ''});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_dateController.text.isEmpty) {
      _dateController.text = DateFormat.yMd(context.locale.languageCode).format(_selectedDeadline);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, requestFullMetadata: false);
    if (pickedFile != null) setState(() => _pickedImage = pickedFile);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100.0,
            pinned: true,
            backgroundColor: colorScheme.primary,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onPrimary, size: 20),
              onPressed: () => context.pop(),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                "edit_announcement.title".tr(),
                style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(color: colorScheme.primary.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel("edit_announcement.field_title".tr(), Icons.title_rounded, colorScheme),
                    _buildCustomTextField(_titleController, colorScheme, hint: "edit_announcement.hint_title".tr()),
                    const SizedBox(height: 25),

                    _buildFieldLabel("edit_announcement.field_target_role".tr(), Icons.military_tech, colorScheme),
                    _buildTargetRoleDropdown(colorScheme),
                    const SizedBox(height: 25),

                    if (_selectedTargetRole != 'general') ...[
                      _buildFieldLabel("edit_announcement.field_college".tr(), Icons.domain, colorScheme),
                      _buildCollegeDropdown(colorScheme),
                      const SizedBox(height: 25),

                      _buildFieldLabel("edit_announcement.field_department".tr(), Icons.meeting_room, colorScheme),
                      _buildDepartmentDropdown(colorScheme),
                      const SizedBox(height: 25),
                    ],

                    _buildFieldLabel("edit_announcement.field_desc".tr(), Icons.subject_rounded, colorScheme),
                    _buildCustomTextField(_bodyController, colorScheme, hint: "edit_announcement.hint_desc".tr(), maxLines: 4),
                    const SizedBox(height: 25),

                    _buildFieldLabel("edit_announcement.field_image".tr(), Icons.image_outlined, colorScheme),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                        ),
                        child: _pickedImage != null
                            ? ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(File(_pickedImage!.path), fit: BoxFit.cover))
                            : (widget.announcement?.imageUrl != null && widget.announcement!.imageUrl!.isNotEmpty)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.announcement!.imageUrl!,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Center(child: CircularProgressIndicator(color: colorScheme.secondary)),
                                      errorWidget: (_, __, ___) => Icon(Icons.broken_image, color: colorScheme.error, size: 40),
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_outlined, size: 45, color: colorScheme.secondary.withOpacity(0.7)),
                                      const SizedBox(height: 8),
                                      Text("edit_announcement.hint_image".tr(), style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5))),
                                    ],
                                  ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel("edit_announcement.field_date".tr(), Icons.calendar_month_rounded, colorScheme),
                              _buildDateField(colorScheme),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel("edit_announcement.field_status".tr(), Icons.info_outline_rounded, colorScheme),
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
                            child: Text("common.cancel".tr(), style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5))),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () => _handleUpdate(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.secondary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            child: Text("edit_announcement.save_button".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildCollegeDropdown(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCollegeId,
          isExpanded: true,
          hint: Text("edit_announcement.hint_college".tr()),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: colorScheme.secondary),
          style: TextStyle(color: colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w600),
          onChanged: (val) {
            setState(() {
              _selectedCollegeId = val;
              _selectedCollegeName = _colleges.firstWhere((c) => c['id'] == val)['name'];
              _selectedDepartmentId = null;
              _selectedDepartmentName = null;
            });
          },
          items: _colleges.map((c) => DropdownMenuItem(value: c['id'], child: Text(c['name']!))).toList(),
        ),
      ),
    );
  }

  Widget _buildDepartmentDropdown(ColorScheme colorScheme) {
    final filteredDepts = _departments.where((d) => d['collegeId'] == _selectedCollegeId).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDepartmentId,
          isExpanded: true,
          hint: Text("edit_announcement.hint_department".tr()),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: colorScheme.secondary),
          style: TextStyle(color: colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w600),
          onChanged: (val) {
            setState(() {
              _selectedDepartmentId = val;
              _selectedDepartmentName = filteredDepts.firstWhere((d) => d['id'] == val)['name'];
            });
          },
          items: filteredDepts.map((d) => DropdownMenuItem(value: d['id'], child: Text(d['name']!))).toList(),
        ),
      ),
    );
  }

  Widget _buildTargetRoleDropdown(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTargetRole,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: colorScheme.secondary),
          style: TextStyle(color: colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w600),
          onChanged: (val) {
            setState(() {
              _selectedTargetRole = val!;
              if (_selectedTargetRole == 'general') {
                _selectedCollegeId = null;
                _selectedCollegeName = null;
                _selectedDepartmentId = null;
                _selectedDepartmentName = null;
              }
            });
          },
          items: AnnouncementModel.targetRoleList.map((v) => DropdownMenuItem(value: v, child: Text(v.tr()))).toList(),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, IconData icon, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4, right: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.secondary),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colorScheme.primary)),
        ],
      ),
    );
  }

  Widget _buildCustomTextField(TextEditingController controller, ColorScheme colorScheme, {int maxLines = 1, required String hint}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.2))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: colorScheme.secondary, width: 1.5)),
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
            _dateController.text = DateFormat.yMd(context.locale.languageCode).format(pickedDate);
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
            Text(_dateController.text, style: TextStyle(fontSize: 13, color: colorScheme.onSurface)),
            Icon(Icons.calendar_today_rounded, size: 16, color: colorScheme.secondary),
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
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: colorScheme.secondary),
          style: TextStyle(color: colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w600),
          onChanged: (val) => setState(() => _selectedStatus = val!),
          items: AnnouncementModel.statusList.map((v) => DropdownMenuItem(value: v, child: Text("announce.$v".tr()))).toList(),
        ),
      ),
    );
  }

  void _handleUpdate(BuildContext context) async {
    if (_titleController.text.trim().isEmpty || _bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("edit_announcement.error_title_desc_required".tr())));
      return;
    }

    if (_selectedTargetRole != 'general' && (_selectedCollegeId == null || _selectedDepartmentId == null)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("edit_announcement.error_college_dept_required".tr())));
      return;
    }

    if (widget.announcement != null) {
      final updatedModel = widget.announcement!.copyWith(
        title: _titleController.text,
        description: _bodyController.text,
        status: _selectedStatus,
        deadline: _selectedDeadline,
        targetRole: _selectedTargetRole,
        collegeId: _selectedCollegeId,
        collegeName: _selectedCollegeName,
        departmentId: _selectedDepartmentId,
        departmentName: _selectedDepartmentName,
      );
      await context.read<AnnouncementCubit>().updateAnnouncement(updatedModel, imagePath: _pickedImage?.path);
    } else {
      final newAnnouncement = AnnouncementModel(
        title: _titleController.text,
        description: _bodyController.text,
        status: _selectedStatus,
        deadline: _selectedDeadline,
        targetRole: _selectedTargetRole,
        createdAt: DateTime.now(),
        collegeId: _selectedCollegeId,
        collegeName: _selectedCollegeName,
        departmentId: _selectedDepartmentId,
        departmentName: _selectedDepartmentName,
      );
      await context.read<AnnouncementCubit>().addAnnouncement(newAnnouncement, imagePath: _pickedImage?.path);
    }

    if (context.mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("edit_announcement.success_msg".tr()), backgroundColor: Theme.of(context).colorScheme.primary),
      );
    }
  }
}