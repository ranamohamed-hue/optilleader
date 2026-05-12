import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:optialeader/core/theming/app_color.dart';
import 'package:optialeader/core/theming/app_text_style.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_state.dart';

class AcademicControllers {
  final TextEditingController degree = TextEditingController();
  final TextEditingController major = TextEditingController();
  final TextEditingController date = TextEditingController();
  final TextEditingController place = TextEditingController();

  void dispose() {
    degree.dispose();
    major.dispose();
    date.dispose();
    place.dispose();
  }

  Map<String, dynamic> toMap() => {
    'degree': degree.text.trim(),
    'major': major.text.trim(),
    'date': date.text.trim(),
    'place': place.text.trim(),
  };
}

class AddDoctorPage extends StatefulWidget {
  final String? existingUid; // 🟢 [إضافة] استقبال الـ UID لو جايين من البحث

  const AddDoctorPage({super.key, this.existingUid}); // 🟢 [تعديل]

  @override
  State<AddDoctorPage> createState() => _AddDoctorPageState();
}

class _AddDoctorPageState extends State<AddDoctorPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameAr = TextEditingController();
  final _nameEn = TextEditingController();
  final _nationalityAr = TextEditingController();
  final _nationalityEn = TextEditingController();
  final _currentJobAr = TextEditingController();
  final _currentJobEn = TextEditingController();
  final _nationalId = TextEditingController();
  final _employeeId = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _addressAr = TextEditingController();
  final _addressEn = TextEditingController();

  DateTime? birthDate;

  final Map<String, String> statusMapping = {
    "أعزب": "Single",
    "متزوج": "Married",
    "أرمل": "Widowed",
    "مطلق": "Divorced",
  };
  String? selectedStatusAr;
  String? selectedStatusEn;

  List<AcademicControllers> academicControllersList = [];

  bool isOnVacation = false;
  bool hasPermanentPosition = true;
  bool disciplinaryClearance = true;

  bool get isArabic => context.locale.languageCode == 'ar';

  // 🟢 [إضافة] متغير يحدد هل إحنا بنضيف جديد ولا بنعدل على موجود
  bool get isEditing => widget.existingUid != null;

  @override
  void initState() {
    // 🟢 [إضافة] دالة initState عشان نجيب الداتا القديمة لو بنعدل
    super.initState();
    if (isEditing) {
      context.read<DoctorDataCubit>().getDoctorProfile(widget.existingUid!);
    }
  }

  @override
  void dispose() {
    for (var controller in academicControllersList) {
      controller.dispose();
    }
    _nameAr.dispose();
    _nameEn.dispose();
    _nationalityAr.dispose();
    _nationalityEn.dispose();
    _currentJobAr.dispose();
    _currentJobEn.dispose();
    _nationalId.dispose();
    _employeeId.dispose();
    _email.dispose();
    _phone.dispose();
    _addressAr.dispose();
    _addressEn.dispose();
    super.dispose();
  }

  void _onSavePressed() {
    if (_formKey.currentState!.validate()) {
      if (birthDate == null && !isEditing) {
        // 🟢 [تعديل] مسموش يسيبه فاضي غير لما بيضيف جديد
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("add_doctor.validate_birth_date".tr())),
        );
        return;
      }

      // 🟢 [تعديل] لو بنعدل نستخدم الـ ID القديم، ولو بنضيف نولد ID جديد
      final String uidToSave = isEditing
          ? widget.existingUid!
          : FirebaseFirestore.instance.collection('Users').doc().id;

      final doctorModel = DoctorProfileModel(
        uid: uidToSave, // 🟢 [تعديل] استخدام الـ ID الصح
        nameAr: _nameAr.text.trim(),
        nameEn: _nameEn.text.trim(),
        nationalityAr: _nationalityAr.text.trim(),
        nationalityEn: _nationalityEn.text.trim(),
        currentJobAr: _currentJobAr.text.trim(),
        currentJobEn: _currentJobEn.text.trim(),
        socialStatusAr: selectedStatusAr ?? '',
        socialStatusEn: selectedStatusEn ?? '',
        nationalId: _nationalId.text.trim(),
        employeeId: _employeeId.text.trim(),
        birthDate: birthDate,
        profileImage: "",
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        addressAr: _addressAr.text.trim(),
        addressEn: _addressEn.text.trim(),
        academicHistory: academicControllersList.map((e) => e.toMap()).toList(),
        disciplinaryClearance: disciplinaryClearance,
        hasPermanentPosition: hasPermanentPosition,
        isOnVacation: isOnVacation,
        isActive: true,
      );

      context.read<DoctorDataCubit>().saveDoctorData(doctorModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<DoctorDataCubit, DoctorDataState>(
      listenWhen: (prev, curr) =>
          curr is DoctorSuccess ||
          curr is DoctorError ||
          curr is DoctorLoaded, // 🟢 [تعديل] إضافة DoctorLoaded
      listener: (context, state) {
        if (state is DoctorLoaded) {
          // 🟢 [إضافة] بلوك تعبئة الفيلدات بالداتا القديمة
          final doc = state.doctor!;
          _nameAr.text = doc.nameAr;
          _nameEn.text = doc.nameEn;
          _nationalityAr.text = doc.nationalityAr;
          _nationalityEn.text = doc.nationalityEn;
          _currentJobAr.text = doc.currentJobAr;
          _currentJobEn.text = doc.currentJobEn;
          _nationalId.text = doc.nationalId;
          _employeeId.text = doc.employeeId;
          _email.text = doc.email;
          _phone.text = doc.phone;
          _addressAr.text = doc.addressAr;
          _addressEn.text = doc.addressEn;
          birthDate = doc.birthDate;
          selectedStatusAr = doc.socialStatusAr;
          selectedStatusEn = doc.socialStatusEn;
          disciplinaryClearance = doc.disciplinaryClearance;
          hasPermanentPosition = doc.hasPermanentPosition;
          isOnVacation = doc.isOnVacation;

          academicControllersList.clear();
          for (var item in doc.academicHistory) {
            final ctrl = AcademicControllers();
            ctrl.degree.text = item['degree'] ?? '';
            ctrl.major.text = item['major'] ?? '';
            ctrl.date.text = item['date'] ?? '';
            ctrl.place.text = item['place'] ?? '';
            academicControllersList.add(ctrl);
          }
          setState(() {}); // تحديث الشاشة عشان تتعرض الداتا
        } else if (state is DoctorSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              // 🟢 [تعديل] تغيير رسالة النجاح حسب الحالة
              content: Text(
                isEditing ? "تم التعديل بنجاح" : "add_doctor.success_msg".tr(),
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state is DoctorError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? "error".tr()),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          // 🟢 [تعديل] تغيير العنوان حسب الحالة
          title: Text(
            isEditing ? "تعديل بيانات الدكتور" : "add_doctor.title".tr(),
            style: theme.appBarTheme.titleTextStyle,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => setState(() {
                _formKey.currentState?.reset();
                academicControllersList.clear();
                birthDate = null;
              }),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildSectionCard(
                  "add_doctor.identity_job".tr(),
                  Icons.person_pin_rounded,
                  [
                    _buildVerticalDoubleField(
                      "add_doctor.name_ar".tr(),
                      _nameAr,
                      "add_doctor.name_en".tr(),
                      _nameEn,
                      Icons.person,
                    ),
                    SizedBox(height: 15.h),
                    _buildVerticalDoubleField(
                      "add_doctor.nat_ar".tr(),
                      _nationalityAr,
                      "add_doctor.nat_en".tr(),
                      _nationalityEn,
                      Icons.flag,
                    ),
                    SizedBox(height: 15.h),
                    _buildSocialStatusDropdown(),
                    SizedBox(height: 15.h),
                    _buildVerticalDoubleField(
                      "add_doctor.job_ar".tr(),
                      _currentJobAr,
                      "add_doctor.job_en".tr(),
                      _currentJobEn,
                      Icons.work,
                    ),
                    SizedBox(height: 15.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            "add_doctor.national_id".tr(),
                            _nationalId,
                            Icons.badge,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _buildField(
                            "add_doctor.employee_id".tr(),
                            _employeeId,
                            Icons.work_history,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    _buildDatePicker(
                      "add_doctor.birth_date".tr(),
                      birthDate,
                      (date) => setState(() => birthDate = date),
                    ),
                  ],
                ),
                _buildSectionCard(
                  "add_doctor.contact_info".tr(),
                  Icons.contact_phone,
                  [
                    _buildField(
                      "add_doctor.email".tr(),
                      _email,
                      Icons.alternate_email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildField(
                      "add_doctor.phone".tr(),
                      _phone,
                      Icons.phone_android,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 15.h),
                    _buildVerticalDoubleField(
                      "add_doctor.address_ar".tr(),
                      _addressAr,
                      "add_doctor.address_en".tr(),
                      _addressEn,
                      Icons.location_on,
                    ),
                  ],
                ),
                _buildSectionCard(
                  "add_doctor.academic_history".tr(),
                  Icons.school,
                  [
                    ...academicControllersList.asMap().entries.map(
                      (entry) => _buildAcademicEntry(entry.key, entry.value),
                    ),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => setState(
                          () => academicControllersList.add(
                            AcademicControllers(),
                          ),
                        ),
                        icon: const Icon(
                          Icons.add_circle,
                          color: AppColors.darkGold,
                        ),
                        label: Text(
                          "add_doctor.add_degree".tr(),
                          style: TextStyle(color: AppColors.navyDark),
                        ),
                      ),
                    ),
                  ],
                ),
                _buildSectionCard(
                  "add_doctor.eligibility".tr(),
                  Icons.verified_user,
                  [
                    _buildSwitch(
                      "add_doctor.clearance".tr(),
                      disciplinaryClearance,
                      (v) => setState(() => disciplinaryClearance = v),
                    ),
                    _buildSwitch(
                      "add_doctor.permanent_pos".tr(),
                      hasPermanentPosition,
                      (v) => setState(() => hasPermanentPosition = v),
                    ),
                    _buildSwitch(
                      "add_doctor.on_vacation".tr(),
                      isOnVacation,
                      (v) => setState(() => isOnVacation = v),
                    ),
                  ],
                ),
                SizedBox(height: 30.h),
                _buildSaveButton(),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Methods --- (مفيش تعديلات هنا)
  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      margin: EdgeInsets.only(bottom: 20.h),
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.darkGold, size: 22.sp),
                SizedBox(width: 10.w),
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.navyDark,
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    IconData? icon, {
    bool isEn = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      textAlign: isEn
          ? TextAlign.left
          : (isArabic ? TextAlign.right : TextAlign.left),
      validator: (v) => v!.isEmpty ? "add_doctor.required".tr() : null,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null
            ? Icon(icon, color: AppColors.navyLight)
            : null,
      ),
    );
  }

  Widget _buildVerticalDoubleField(
    String labelAr,
    TextEditingController ctrlAr,
    String labelEn,
    TextEditingController ctrlEn,
    IconData icon,
  ) {
    return Column(
      children: [
        _buildField(labelAr, ctrlAr, icon),
        SizedBox(height: 8.h),
        _buildField(labelEn, ctrlEn, null, isEn: true),
      ],
    );
  }

  Widget _buildSocialStatusDropdown() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdownField(
            "add_doctor.social_status".tr(),
            statusMapping.keys.toList(),
            selectedStatusAr,
            (val) => setState(() {
              selectedStatusAr = val;
              selectedStatusEn = statusMapping[val];
            }),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildDropdownField(
            "Social Status",
            statusMapping.values.toList(),
            selectedStatusEn,
            (val) => setState(() {
              selectedStatusEn = val;
              selectedStatusAr = statusMapping.entries
                  .firstWhere((e) => e.value == val)
                  .key;
            }),
            isEn: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> items,
    String? value,
    Function(String?) onChanged, {
    bool isEn = false,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map(
            (s) => DropdownMenuItem(
              value: s,
              child: Text(s, style: AppTextStyles.bodySmall),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? "add_doctor.required".tr() : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: isEn
            ? null
            : const Icon(Icons.info_outline, color: AppColors.navyLight),
      ),
    );
  }

  Widget _buildAcademicEntry(int index, AcademicControllers controllers) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.navyLight.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${"add_doctor.degree".tr()} ${index + 1}",
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () =>
                    setState(() => academicControllersList.removeAt(index)),
                icon: const Icon(Icons.delete_forever, color: AppColors.error),
              ),
            ],
          ),
          _buildSmallInput("add_doctor.degree_hint".tr(), controllers.degree),
          SizedBox(height: 8.h),
          _buildSmallInput("add_doctor.major_hint".tr(), controllers.major),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildSmallInput(
                  "add_doctor.year".tr(),
                  controllers.date,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildSmallInput(
                  "add_doctor.university".tr(),
                  controllers.place,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallInput(String hint, TextEditingController ctrl) {
    return TextFormField(
      controller: ctrl,
      style: AppTextStyles.bodySmall,
      textAlign: isArabic ? TextAlign.right : TextAlign.left,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      ),
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime? date,
    Function(DateTime) onPick,
  ) {
    return InkWell(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime(1990),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date == null ? label : DateFormat('yyyy-MM-dd').format(date),
              style: AppTextStyles.bodyMedium,
            ),
            const Icon(Icons.calendar_month, color: AppColors.navyDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch(String t, bool v, Function(bool) c) => SwitchListTile(
    title: Text(t, style: AppTextStyles.bodyMedium),
    value: v,
    onChanged: c,
    activeColor: AppColors.darkGold,
  );

  Widget _buildSaveButton() {
    return BlocBuilder<DoctorDataCubit, DoctorDataState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 55.h,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navyDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onPressed: state is DoctorLoading ? null : _onSavePressed,
            child: state is DoctorLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    isEditing
                        ? "حفظ التعديلات"
                        : "add_doctor.save_button".tr(), // 🟢 [تعديل]
                    style: AppTextStyles.labelLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
