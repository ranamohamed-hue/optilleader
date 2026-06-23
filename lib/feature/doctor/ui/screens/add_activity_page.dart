import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/helper/file_halper.dart';
import 'package:uuid/uuid.dart';
import 'package:optialeader/feature/doctor/logic/activities/mandatory_leadership_data.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';
import 'package:optialeader/feature/doctor/logic/activities/activity_cubit.dart';
import 'package:optialeader/feature/doctor/logic/activities/acativity_state.dart';
import 'package:optialeader/feature/doctor/ui/widgets/file_picker_field.dart';
import 'package:optialeader/feature/doctor/data/model/courses_model.dart';
import 'package:optialeader/feature/doctor/data/model/conferance_model.dart';

class AddActivityPage extends StatefulWidget {
  final String doctorUid;
  const AddActivityPage({super.key, required this.doctorUid});

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _organizationController = TextEditingController();
  final _dateController = TextEditingController();
  final _durationHoursController = TextEditingController();

  String _selectedType = 'conference';

  // لمؤتمرات
  bool _isInternational = true;
  bool _isSpecialized = true;
  bool _isPublished = false;
  ParticipationType _participationType = ParticipationType.paperPresentation;

  // لدورات
  CourseCategory _selectedCategory = CourseCategory.administrative;
  CourseScope _selectedScope = CourseScope.international;
  CourseType _courseType = CourseType.graded;

  // قائمة الدورات التأهيلية من الكلاس الموحد
  final List<Map<String, String>> _mandatoryCoursesList =
      MandatoryLeadershipData.courses;

  final Set<String> _selectedMandatoryCourses = {};
  final Map<String, PickedFileData?> _mandatoryCourseFiles = {};

  PickedFileData? _proofFile;

  @override
  void dispose() {
    _titleController.dispose();
    _organizationController.dispose();
    _dateController.dispose();
    _durationHoursController.dispose();
    super.dispose();
  }

  void _submit() {
    // التحقق من الحقول المطلوبة للنشاط العادي
    final hasNormalActivity =
        _titleController.text.trim().isNotEmpty ||
        _organizationController.text.trim().isNotEmpty;

    if (hasNormalActivity && !_formKey.currentState!.validate()) return;

    // التحقق من ملف الشهادة للنشاط العادي
    if (hasNormalActivity) {
      if (_selectedType == 'conference' && _proofFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('addActivity.fileRequired'.tr()),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_selectedType == 'course' &&
          _courseType == CourseType.graded &&
          _proofFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('addActivity.fileRequired'.tr()),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // التحقق من ملفات الشهادات للدورات التأهيلية المختارة
    if (_selectedMandatoryCourses.isNotEmpty) {
      for (var courseData in _mandatoryCoursesList) {
        final key = courseData['key']!;
        if (!_selectedMandatoryCourses.contains(key)) continue;

        if (_mandatoryCourseFiles[key] == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${courseData['titleAr']} - ${'addActivity.fileRequired'.tr()}',
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }
      }
    }

    // إذا مفيش نشاط عادي ولا دورات تأهيلية، لا تفعل شيء
    if (!hasNormalActivity && _selectedMandatoryCourses.isEmpty) return;

    final cubit = context.read<ActivityCubit>();

    // حفظ النشاط العادي (مؤتمر أو دورة تقييمية)
    if (hasNormalActivity) {
      if (_selectedType == 'conference') {
        final conf = ConferenceModel(
          id: const Uuid().v4(),
          title: _titleController.text.trim(),
          isInternational: _isInternational,
          isSpecialized: _isSpecialized,
          isPublished: _isPublished,
          participationType: _participationType,
          certificateUrl: '',
          status: VerificationStatus.pending,
        );
        cubit.addConference(
          doctorUid: widget.doctorUid,
          conference: conf,
          certFile: _proofFile!.file,
        );
      } else if (_courseType == CourseType.graded) {
        final course = CourseModel(
          id: const Uuid().v4(),
          title: _titleController.text.trim(),
          organization: _organizationController.text.trim(),
          date: _dateController.text.trim(),
          durationHours: int.tryParse(_durationHoursController.text.trim()),
          type: _courseType,
          courseCategory: _selectedCategory,
          courseScope: _selectedScope,
          certificateUrl: '',
          status: VerificationStatus.pending,
        );
        cubit.addCourse(
          doctorUid: widget.doctorUid,
          course: course,
          certFile: _proofFile!.file,
        );
      }
    }

    // حفظ الدورات التأهيلية المختارة (بالاسم العربي الحقيقي)
    if (_selectedMandatoryCourses.isNotEmpty) {
      for (var courseData in _mandatoryCoursesList) {
        final key = courseData['key']!;
        if (!_selectedMandatoryCourses.contains(key)) continue;

        final file = _mandatoryCourseFiles[key]!;

        final mandatoryCourse = CourseModel(
          id: const Uuid().v4(),
          title: courseData['titleAr']!,
          organization: '',
          date: '',
          type: CourseType.mandatory,
          courseCategory: CourseCategory.none,
          courseScope: CourseScope.none,
          certificateUrl: '',
          status: VerificationStatus.approved,
        );
        cubit.addCourse(
          doctorUid: widget.doctorUid,
          course: mandatoryCourse,
          certFile: file.file,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActivityCubit, ActivityState>(
      listener: (context, state) {
        if (state is ActivitySuccess) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('addActivity.success'.tr()),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ActivityError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ActivityLoading;
        return Scaffold(
          appBar: AppBar(
            title: Text('addActivity.title'.tr()),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // قسم الدورات التأهيلية
                  _buildMandatoryCoursesSection(),

                  SizedBox(height: 20.h),

                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      labelText: 'addActivity.type'.tr(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'conference',
                        child: Text('addActivity.typeConferenceWorkshop'.tr()),
                      ),
                      DropdownMenuItem(
                        value: 'course',
                        child: Text('addActivity.typeCourse'.tr()),
                      ),
                    ],
                    onChanged: (v) => setState(() {
                      _selectedType = v!;
                      _courseType = CourseType.graded;
                    }),
                  ),

                  SizedBox(height: 12.h),

                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'addActivity.activityTitle'.tr(),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? 'validation.required'.tr() : null,
                  ),

                  SizedBox(height: 12.h),

                  TextFormField(
                    controller: _organizationController,
                    decoration: InputDecoration(
                      labelText: 'addActivity.organization'.tr(),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? 'validation.required'.tr() : null,
                  ),

                  SizedBox(height: 12.h),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _dateController,
                          decoration: InputDecoration(
                            labelText: 'addActivity.date'.tr(),
                          ),
                          validator: (v) =>
                              v!.isEmpty ? 'validation.required'.tr() : null,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _durationHoursController,
                          decoration: InputDecoration(
                            labelText: 'addActivity.durationHours'.tr(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // حقول المؤتمرات
                  if (_selectedType == 'conference') ...[
                    SwitchListTile(
                      title: Text('addActivity.isInternational'.tr()),
                      value: _isInternational,
                      onChanged: (v) => setState(() => _isInternational = v),
                    ),
                    SwitchListTile(
                      title: Text('addActivity.isSpecialized'.tr()),
                      value: _isSpecialized,
                      onChanged: (v) => setState(() => _isSpecialized = v),
                    ),
                    SwitchListTile(
                      title: Text('addActivity.isPublished'.tr()),
                      value: _isPublished,
                      onChanged: (v) => setState(() => _isPublished = v),
                    ),
                    DropdownButtonFormField<ParticipationType>(
                      value: _participationType,
                      decoration: InputDecoration(
                        labelText: 'addActivity.participationType'.tr(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: ParticipationType.paperPresentation,
                          child: Text('addActivity.partPaperPresentation'.tr()),
                        ),
                        DropdownMenuItem(
                          value: ParticipationType.abstractPresentation,
                          child: Text(
                            'addActivity.partAbstractPresentation'.tr(),
                          ),
                        ),
                        DropdownMenuItem(
                          value: ParticipationType.attendanceOnly,
                          child: Text('addActivity.partAttendanceOnly'.tr()),
                        ),
                      ],
                      onChanged: (v) => setState(() => _participationType = v!),
                    ),
                  ],

                  // حقول الدورات التقييمية
                  if (_selectedType == 'course' &&
                      _courseType == CourseType.graded) ...[
                    DropdownButtonFormField<CourseCategory>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'addActivity.courseCategory'.tr(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: CourseCategory.administrative,
                          child: Text('addActivity.catAdmin'.tr()),
                        ),
                        DropdownMenuItem(
                          value: CourseCategory.specialized,
                          child: Text('addActivity.catSpec'.tr()),
                        ),
                        DropdownMenuItem(
                          value: CourseCategory.general,
                          child: Text('addActivity.catGeneral'.tr()),
                        ),
                      ],
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                    ),
                    SizedBox(height: 12.h),
                    DropdownButtonFormField<CourseScope>(
                      value: _selectedScope,
                      decoration: InputDecoration(
                        labelText: 'addActivity.courseScope'.tr(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: CourseScope.international,
                          child: Text('addActivity.scopeInt'.tr()),
                        ),
                        DropdownMenuItem(
                          value: CourseScope.local,
                          child: Text('addActivity.scopeLocal'.tr()),
                        ),
                      ],
                      onChanged: (v) => setState(() => _selectedScope = v!),
                    ),
                  ],

                  SizedBox(height: 20.h),

                  // ملف الشهادة للنشاط العادي فقط
                  FilePickerField(
                    label: 'addActivity.proofFile'.tr(),
                    selectedFile: _proofFile,
                    onFileSelected: (file) => setState(() => _proofFile = file),
                  ),

                  SizedBox(height: 30.h),

                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'addActivity.submit'.tr(),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ويدجت قسم الدورات التأهيلية
  Widget _buildMandatoryCoursesSection() {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.deepPurple, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.playlist_add_check_rounded,
                color: Colors.deepPurple,
                size: 22.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'addActivity.mandatory_courses_title'.tr(),
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade900,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'addActivity.mandatory_courses_subtitle'.tr(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.deepPurple.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),

          ..._mandatoryCoursesList.map((courseData) {
            final key = courseData['key']!;
            final titleAr = courseData['titleAr']!;
            final isSelected = _selectedMandatoryCourses.contains(key);

            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedMandatoryCourses.remove(key);
                          _mandatoryCourseFiles.remove(key);
                        } else {
                          _selectedMandatoryCourses.add(key);
                        }
                      });
                    },
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank,
                          color: isSelected ? Colors.deepPurple : Colors.grey,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            titleAr,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.sp,
                              color: isSelected
                                  ? Colors.deepPurple
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected) ...[
                    SizedBox(height: 10.h),
                    FilePickerField(
                      label: '$titleAr - ${'addActivity.proofFile'.tr()}',
                      selectedFile: _mandatoryCourseFiles[key],
                      onFileSelected: (file) =>
                          setState(() => _mandatoryCourseFiles[key] = file),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
