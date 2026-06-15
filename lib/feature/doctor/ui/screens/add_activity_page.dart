import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/helper/file_halper.dart';
import 'package:uuid/uuid.dart';
import 'package:optialeader/feature/doctor/data/model/activities_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';
import 'package:optialeader/feature/doctor/logic/activities/activity_cubit.dart';
import 'package:optialeader/feature/doctor/logic/activities/acativity_state.dart';
import 'package:optialeader/feature/doctor/ui/widgets/file_picker_field.dart';

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
  String _selectedParticipationType = 'attendee';

  // التعديل: القيمة الابتدائية لمنع الخطأ في الـ Dropdown
  CourseCategory _selectedCategory = CourseCategory.administrative;
  CourseScope _selectedScope = CourseScope.international;

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
    if (!_formKey.currentState!.validate()) return;

    final activity = ActivityModel(
      id: const Uuid().v4(),
      type: _selectedType,
      title: _titleController.text.trim(),
      organization: _organizationController.text.trim(),
      date: _dateController.text.trim(),
      durationHours: int.tryParse(_durationHoursController.text.trim()),
      participationType: _selectedParticipationType,
      courseCategory: _selectedType == 'course'
          ? _selectedCategory
          : CourseCategory.none,
      courseScope: _selectedType == 'course'
          ? _selectedScope
          : CourseScope.none,
      status: VerificationStatus.pending,
    );

    context.read<ActivityCubit>().addNewActivity(
      doctorUid: widget.doctorUid,
      activity: activity,
      proofFile: _proofFile?.file,
    );
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
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      labelText: 'addActivity.type'.tr(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'conference',
                        child: Text('addActivity.typeConference'.tr()),
                      ),
                      DropdownMenuItem(
                        value: 'workshop',
                        child: Text('addActivity.typeWorkshop'.tr()),
                      ),
                      DropdownMenuItem(
                        value: 'course',
                        child: Text('addActivity.typeCourse'.tr()),
                      ),
                    ],
                    onChanged: (v) => setState(() {
                      _selectedType = v!;
                      // لو رجعنا لغير الدورة، نرجع القيم الافتراضية
                      if (_selectedType != 'course') {
                        _selectedCategory = CourseCategory.administrative;
                        _selectedScope = CourseScope.international;
                      }
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
                  SizedBox(height: 12.h),

                  DropdownButtonFormField<String>(
                    value: _selectedParticipationType,
                    decoration: InputDecoration(
                      labelText: 'addActivity.participationType'.tr(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'attendee',
                        child: Text('addActivity.partAttendee'.tr()),
                      ),
                      DropdownMenuItem(
                        value: 'speaker',
                        child: Text('addActivity.partSpeaker'.tr()),
                      ),
                      DropdownMenuItem(
                        value: 'organizer',
                        child: Text('addActivity.partOrganizer'.tr()),
                      ),
                    ],
                    onChanged: (v) =>
                        setState(() => _selectedParticipationType = v!),
                  ),

                  if (_selectedType == 'course') ...[
                    SizedBox(height: 12.h),
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}