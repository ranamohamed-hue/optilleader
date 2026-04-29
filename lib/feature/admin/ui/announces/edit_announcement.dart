import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  late DateTime _selectedDeadline; // لتخزين التاريخ الحقيقي

  @override
  void initState() {
    super.initState();
    // تهيئة البيانات من الموديل
    _titleController = TextEditingController(text: widget.announcement.title);
    _bodyController = TextEditingController(
      text: widget.announcement.description,
    );
    _selectedDeadline = widget.announcement.deadline;
    _dateController = TextEditingController(
      text:
          "${_selectedDeadline.day}/${_selectedDeadline.month}/${_selectedDeadline.year}",
    );
    _selectedStatus = widget.announcement.status;
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
    final primaryNavy = theme.colorScheme.primary;
    final accentGold = theme.colorScheme.secondary;
    final softBeige = theme.scaffoldBackgroundColor;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: softBeige,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 80.0,
              pinned: true,
              backgroundColor: primaryNavy,
              elevation: 0,
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
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  "تعديل الإعلان",
                  style: TextStyle(
                    color: accentGold,
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
                      _buildFieldLabel(
                        "عنوان الإعلان",
                        Icons.title_rounded,
                        accentGold,
                        primaryNavy,
                      ),
                      _buildCustomTextField(
                        _titleController,
                        accentGold,
                        softBeige,
                        primaryNavy,
                        hint: "أدخل العنوان...",
                      ),

                      const SizedBox(height: 25),

                      _buildFieldLabel(
                        "محتوى الإعلان",
                        Icons.subject_rounded,
                        accentGold,
                        primaryNavy,
                      ),
                      _buildCustomTextField(
                        _bodyController,
                        accentGold,
                        softBeige,
                        primaryNavy,
                        hint: "أدخل التفاصيل...",
                        maxLines: 5,
                      ),

                      const SizedBox(height: 25),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel(
                                  "الموعد النهائي",
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
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFieldLabel(
                                  "الحالة",
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

                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                "إلغاء",
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // تجميع البيانات المعدلة باستخدام copyWith
                                final updatedModel = widget.announcement.copyWith(
                                  title: _titleController.text,
                                  description: _bodyController.text,
                                  status: _selectedStatus,
                                  deadline:
                                      _selectedDeadline, // نستخدم الـ DateTime اللي اتحدث
                                );

                                // استدعاء الكيوبيت
                                context
                                    .read<AnnouncementCubit>()
                                    .updateAnnouncement(updatedModel);

                                Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("تم حفظ التعديلات بنجاح"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryNavy,
                                foregroundColor: accentGold,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                "حفظ التعديلات",
                                style: TextStyle(fontWeight: FontWeight.bold),
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
      ),
    );
  }

  // --- Widgets المساعدة ---

  Widget _buildFieldLabel(String label, IconData icon, Color gold, Color navy) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 4),
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
        filled: true,
        fillColor: beige.withOpacity(0.3),
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
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          setState(() {
            _selectedDeadline = pickedDate; // تحديث التاريخ الحقيقي
            _dateController.text =
                "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: beige.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _dateController.text,
              style: TextStyle(fontSize: 14, color: navy),
            ),
            Icon(Icons.calendar_today_rounded, size: 18, color: gold),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(Color gold, Color beige, Color navy) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: beige.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: gold),
          isExpanded: true,
          style: TextStyle(
            color: navy,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          onChanged: (val) => setState(() => _selectedStatus = val!),
          items: [
            'Active',
            'Pending',
            'Closed',
          ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
        ),
      ),
    );
  }
}
