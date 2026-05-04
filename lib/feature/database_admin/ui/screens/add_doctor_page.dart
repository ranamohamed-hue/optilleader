import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:optialeader/core/theming/app_color.dart';
import 'package:optialeader/core/theming/app_text_style.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_state.dart';

// كلاس مساعد لإدارة وحدات التحكم لكل درجة علمية
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
  const AddDoctorPage({super.key});

  @override
  State<AddDoctorPage> createState() => _AddDoctorPageState();
}

class _AddDoctorPageState extends State<AddDoctorPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
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

  // الحالة الاجتماعية
  final Map<String, String> statusMapping = {
    "أعزب": "Single",
    "متزوج": "Married",
    "أرمل": "Widowed",
    "مطلق": "Divorced",
  };
  String? selectedStatusAr;
  String? selectedStatusEn;

  // قائمة التحكم بالتاريخ الأكاديمي
  List<AcademicControllers> academicControllersList = [];

  // الأهلية
  bool isOnVacation = false;
  bool hasPermanentPosition = true;
  bool disciplinaryClearance = true;

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
      if (birthDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("يرجى اختيار تاريخ الميلاد")),
        );
        return;
      }

      final doctorModel = DoctorProfileModel(
        uid: null,
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
      listenWhen: (prev, curr) => curr is DoctorSuccess || curr is DoctorError,
      listener: (context, state) {
        if (state is DoctorSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("تم حفظ ملف الدكتور بنجاح"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state is DoctorError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? "خطأ غير معروف"),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            "استمارة بيانات الدكتور الشاملة",
            style: theme.appBarTheme.titleTextStyle,
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildSectionCard(
                  "بيانات الهوية والوظيفة الحالية",
                  Icons.person_pin_rounded,
                  [
                    _buildVerticalDoubleField(
                      "الاسم بالكامل (عربي)",
                      _nameAr,
                      "Full Name (English)",
                      _nameEn,
                      Icons.person,
                    ),
                    SizedBox(height: 15.h),
                    _buildVerticalDoubleField(
                      "الجنسية (عربي)",
                      _nationalityAr,
                      "Nationality (English)",
                      _nationalityEn,
                      Icons.flag,
                    ),
                    SizedBox(height: 15.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            "الحالة الاجتماعية",
                            statusMapping.keys.toList(),
                            selectedStatusAr,
                            (val) {
                              setState(() {
                                selectedStatusAr = val;
                                selectedStatusEn = statusMapping[val];
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _buildDropdownField(
                            "Social Status",
                            statusMapping.values.toList(),
                            selectedStatusEn,
                            (val) {
                              setState(() {
                                selectedStatusEn = val;
                                selectedStatusAr = statusMapping.entries
                                    .firstWhere((e) => e.value == val)
                                    .key;
                              });
                            },
                            isEn: true,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    _buildVerticalDoubleField(
                      "الوظيفة الحالية (عربي)",
                      _currentJobAr,
                      "Current Job (English)",
                      _currentJobEn,
                      Icons.work,
                    ),
                    SizedBox(height: 15.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            "الرقم القومي",
                            _nationalId,
                            Icons.badge,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _buildField(
                            "الرقم الوظيفي",
                            _employeeId,
                            Icons.work_history,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    _buildDatePicker(
                      "تاريخ الميلاد",
                      birthDate,
                      (date) => setState(() => birthDate = date),
                    ),
                  ],
                ),
                _buildSectionCard(
                  "بيانات التواصل والعنوان",
                  Icons.contact_phone,
                  [
                    _buildField(
                      "البريد الجامعي الرسمي",
                      _email,
                      Icons.alternate_email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildField(
                      "رقم الهاتف الشخصي",
                      _phone,
                      Icons.phone_android,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 15.h),
                    _buildVerticalDoubleField(
                      "العنوان بالتفصيل (عربي)",
                      _addressAr,
                      "Address Details (English)",
                      _addressEn,
                      Icons.location_on,
                    ),
                  ],
                ),
                _buildSectionCard("التاريخ الأكاديمي والوظيفي", Icons.school, [
                  ...academicControllersList.asMap().entries.map((entry) {
                    return _buildAcademicEntry(entry.key, entry.value);
                  }).toList(),
                  SizedBox(height: 10.h),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () => setState(
                        () =>
                            academicControllersList.add(AcademicControllers()),
                      ),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text("إضافة درجة علمية سابقة"),
                    ),
                  ),
                ]),
                _buildSectionCard("مراجعة الأهلية", Icons.verified_user, [
                  _buildSwitch(
                    "خلو من الجزاءات التأديبية",
                    disciplinaryClearance,
                    (v) => setState(() => disciplinaryClearance = v),
                  ),
                  _buildSwitch(
                    "يشغل وظيفة دائمة بالجامعة",
                    hasPermanentPosition,
                    (v) => setState(() => hasPermanentPosition = v),
                  ),
                  _buildSwitch(
                    "هل الدكتور في إجازة حالياً؟",
                    isOnVacation,
                    (v) => setState(() => isOnVacation = v),
                  ),
                ]),
                SizedBox(height: 30.h),
                BlocBuilder<DoctorDataCubit, DoctorDataState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      height: 60.h,
                      child: ElevatedButton(
                        onPressed: state is DoctorLoading
                            ? null
                            : _onSavePressed,
                        child: state is DoctorLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                "حفظ ملف الدكتور بالكامل",
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Widgets المساعدة ---

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      margin: EdgeInsets.only(bottom: 20.h),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.darkGold, size: 22.sp),
                SizedBox(width: 10.w),
                Text(title, style: AppTextStyles.titleMedium),
              ],
            ),
            const Divider(height: 30, thickness: 0.5),
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
      textAlign: isEn ? TextAlign.left : TextAlign.right,
      validator: (v) => v!.isEmpty ? "هذا الحقل مطلوب" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
      ),
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
      validator: (v) => v == null ? "مطلوب" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: isEn ? null : const Icon(Icons.info_outline),
      ),
    );
  }

  Widget _buildAcademicEntry(int index, AcademicControllers controllers) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: AppColors.navyLight.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColors.navyLight.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildSmallInput(
            "الدرجة العلمية (مثلاً: دكتوراة)",
            controllers.degree,
          ),
          SizedBox(height: 8.h),
          _buildSmallInput("التخصص", controllers.major),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(child: _buildSmallInput("السنة", controllers.date)),
              SizedBox(width: 8.w),
              Expanded(child: _buildSmallInput("الجامعة", controllers.place)),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.delete_sweep, color: AppColors.error),
              onPressed: () =>
                  setState(() => academicControllersList.removeAt(index)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallInput(String hint, TextEditingController ctrl) {
    return TextFormField(
      controller: ctrl,
      style: AppTextStyles.bodySmall,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        fillColor: Colors.white,
        filled: true,
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
          initialDate: DateTime(1985),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date == null
                  ? label
                  : "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
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
}
