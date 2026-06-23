import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:optialeader/core/helper/file_halper.dart';
import 'package:optialeader/feature/doctor/data/model/research_paper_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';
import 'package:optialeader/feature/doctor/logic/research_paper/research_paper_cubit.dart';
import 'package:optialeader/feature/doctor/logic/research_paper/research_paper_state.dart';
import 'package:optialeader/feature/doctor/ui/widgets/file_picker_field.dart';

class AddResearchPaperPage extends StatefulWidget {
  final String doctorUid;
  const AddResearchPaperPage({super.key, required this.doctorUid});

  @override
  State<AddResearchPaperPage> createState() => _AddResearchPaperPageState();
}

class _AddResearchPaperPageState extends State<AddResearchPaperPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleArController = TextEditingController();
  final _titleEnController = TextEditingController();
  final _journalNameController = TextEditingController();
  final _issnController = TextEditingController();
  final _impactFactorController = TextEditingController();
  final _publicationYearController = TextEditingController();
  final _authorOrderController = TextEditingController();
  final _totalAuthorsController = TextEditingController();
  final _journalUrlController = TextEditingController();
  final _authorsInSameSpecialtyController = TextEditingController();
  final _reportNumberController = TextEditingController();

  bool _isTopTierJournal = false;

  JournalScope _selectedJournalScope = JournalScope.specialized;
  JournalLevel _selectedJournalLevel = JournalLevel.international;
  IndexingDatabase _selectedIndexDatabase = IndexingDatabase.scopus;

  String? _selectedQuartile;
  Map<String, bool> _localCriteria = {};

  PickedFileData? _paperFile;
  PickedFileData? _indexingProofFile;
  PickedFileData? _certifiedReportFile;

  String _getDbName(IndexingDatabase db) {
    switch (db) {
      case IndexingDatabase.scopus:
        return 'addResearch.dbScopus'.tr();
      case IndexingDatabase.webOfScience:
        return 'addResearch.dbWebOfScience'.tr();
      case IndexingDatabase.local:
        return 'addResearch.dbLocal'.tr();
      case IndexingDatabase.other:
        return 'common.other'.tr();
    }
  }

  bool get _isInternational =>
      _selectedIndexDatabase == IndexingDatabase.scopus ||
      _selectedIndexDatabase == IndexingDatabase.webOfScience;
  bool get _isLocal => _selectedIndexDatabase == IndexingDatabase.local;

  @override
  void dispose() {
    _titleArController.dispose();
    _titleEnController.dispose();
    _journalNameController.dispose();
    _issnController.dispose();
    _impactFactorController.dispose();
    _publicationYearController.dispose();
    _authorOrderController.dispose();
    _totalAuthorsController.dispose();
    _journalUrlController.dispose();
    _authorsInSameSpecialtyController.dispose();
    _reportNumberController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_paperFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('addResearch.fileRequired'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedIndexDatabase != IndexingDatabase.other &&
        _indexingProofFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('addResearch.indexingProofRequired'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final paper = ResearchPaperModel(
      id: const Uuid().v4(),
      titleAr: _titleArController.text.trim(),
      titleEn: _titleEnController.text.trim(),
      journalName: _journalNameController.text.trim(),
      issn: _issnController.text.trim(),
      impactFactor: _impactFactorController.text.trim(),
      publicationYear:
          int.tryParse(_publicationYearController.text.trim()) ?? 0,
      authorOrder: int.tryParse(_authorOrderController.text.trim()) ?? 1,
      totalAuthors: int.tryParse(_totalAuthorsController.text.trim()) ?? 1,
      authorsInSameSpecialty:
          int.tryParse(_authorsInSameSpecialtyController.text.trim()) ?? 1,
      isTopTierJournal: _isTopTierJournal,
      journalScope: _selectedJournalScope,
      journalLevel: _selectedJournalLevel,
      indexingDatabase: _selectedIndexDatabase,
      journalUrl: _journalUrlController.text.trim(),
      quartile: _isInternational ? _selectedQuartile : null,
      isLocalJournal: _isLocal,
      localJournalCriteria: _isLocal ? _localCriteria : null,
      certifiedReportNumber: _reportNumberController.text.trim().isEmpty
          ? null
          : _reportNumberController.text.trim(),
      paperFileUrl: '',
      paperFileType: _paperFile!.type == UploadedFileType.image
          ? 'image'
          : 'pdf',
      status: VerificationStatus.pending,
    );

    context.read<ResearchCubit>().addNewResearch(
      doctorUid: widget.doctorUid,
      paper: paper,
      paperFile: _paperFile!.file,
      indexingProofFile: _indexingProofFile?.file,
      certifiedReportFile: _certifiedReportFile?.file,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ResearchCubit, ResearchState>(
      listener: (context, state) {
        if (state is ResearchSuccess) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('addResearch.success'.tr()),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ResearchError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ResearchLoading;
        return Scaffold(
          appBar: AppBar(
            title: Text('addResearch.title'.tr()),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleArController,
                    decoration: InputDecoration(
                      labelText: 'addResearch.titleAr'.tr(),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? 'validation.required'.tr() : null,
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: _titleEnController,
                    decoration: InputDecoration(
                      labelText: 'addResearch.titleEn'.tr(),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? 'validation.required'.tr() : null,
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: _journalNameController,
                    decoration: InputDecoration(
                      labelText: 'addResearch.journalName'.tr(),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? 'validation.required'.tr() : null,
                  ),
                  SizedBox(height: 12.h),

                  // ✅ تم تصحيح initialValue لـ value
                  DropdownButtonFormField<JournalScope>(
                    value: _selectedJournalScope,
                    decoration: InputDecoration(
                      labelText: 'addResearch.journalScopeLabel'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: JournalScope.specialized,
                        child: Text('addResearch.scopeSpecialized'.tr()),
                      ),
                      DropdownMenuItem(
                        value: JournalScope.nonSpecialized,
                        child: Text('addResearch.scopeNonSpecialized'.tr()),
                      ),
                    ],
                    onChanged: (val) =>
                        setState(() => _selectedJournalScope = val!),
                    validator: (v) =>
                        v == null ? 'validation.required'.tr() : null,
                  ),
                  SizedBox(height: 12.h),

                  DropdownButtonFormField<JournalLevel>(
                    value: _selectedJournalLevel,
                    decoration: InputDecoration(
                      labelText: 'addResearch.journalLevelLabel'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: JournalLevel.international,
                        child: Text('addResearch.levelInternational'.tr()),
                      ),
                      DropdownMenuItem(
                        value: JournalLevel.local,
                        child: Text('addResearch.levelLocal'.tr()),
                      ),
                    ],
                    onChanged: (val) =>
                        setState(() => _selectedJournalLevel = val!),
                    validator: (v) =>
                        v == null ? 'validation.required'.tr() : null,
                  ),
                  SizedBox(height: 12.h),

                  DropdownButtonFormField<IndexingDatabase>(
                    value: _selectedIndexDatabase,
                    decoration: InputDecoration(
                      labelText: 'addResearch.indexingDatabaseLabel'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: IndexingDatabase.scopus,
                        child: Text('addResearch.dbScopus'.tr()),
                      ),
                      DropdownMenuItem(
                        value: IndexingDatabase.webOfScience,
                        child: Text('addResearch.dbWebOfScience'.tr()),
                      ),
                      DropdownMenuItem(
                        value: IndexingDatabase.local,
                        child: Text('addResearch.dbLocal'.tr()),
                      ),
                      DropdownMenuItem(
                        value: IndexingDatabase.other,
                        child: Text('common.other'.tr()),
                      ),
                    ],
                    onChanged: (val) => setState(() {
                      _selectedIndexDatabase = val!;
                      _selectedQuartile = null;
                      _localCriteria = {};
                    }),
                    validator: (v) =>
                        v == null ? 'validation.required'.tr() : null,
                  ),
                  SizedBox(height: 12.h),

                  if (_isInternational) ...[
                    DropdownButtonFormField<String>(
                      value: _selectedQuartile,
                      decoration: InputDecoration(
                        labelText: 'addResearch.quartile'.tr(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      items: ['q1', 'q2', 'q3', 'q4', 'no_if']
                          .map(
                            (q) => DropdownMenuItem(
                              value: q,
                              child: Text(q.toUpperCase()),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedQuartile = val),
                      validator: (v) =>
                          v == null ? 'validation.required'.tr() : null,
                    ),
                    SizedBox(height: 12.h),
                  ],

                  if (_isLocal) ...[
                    _buildLocalCriteriaSection(),
                    SizedBox(height: 12.h),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _issnController,
                          decoration: InputDecoration(
                            labelText: 'addResearch.issn'.tr(),
                          ),
                          validator: (v) =>
                              v!.isEmpty ? 'validation.required'.tr() : null,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: TextFormField(
                          controller: _impactFactorController,
                          decoration: InputDecoration(
                            labelText: 'addResearch.impactFactor'.tr(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _publicationYearController,
                          decoration: InputDecoration(
                            labelText: 'addResearch.publicationYear'.tr(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v!.isEmpty ? 'validation.required'.tr() : null,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _authorOrderController,
                          decoration: InputDecoration(
                            labelText: 'addResearch.authorOrder'.tr(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v!.isEmpty ? 'validation.required'.tr() : null,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _totalAuthorsController,
                          decoration: InputDecoration(
                            labelText: 'addResearch.totalAuthors'.tr(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v!.isEmpty ? 'validation.required'.tr() : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  TextFormField(
                    controller: _authorsInSameSpecialtyController,
                    decoration: InputDecoration(
                      labelText: 'addResearch.authorsInSameSpecialty'.tr(),
                      helperText: 'addResearch.authorsInSameSpecialtyHint'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return 'validation.required'.tr();
                      final sameSpecialty = int.tryParse(v) ?? 0;
                      final authorOrder =
                          int.tryParse(_authorOrderController.text) ?? 0;
                      if (sameSpecialty < authorOrder)
                        return 'addResearch.validationAuthorsOrder'.tr();
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),

                  SwitchListTile(
                    title: Text('addResearch.isTopTierJournal'.tr()),
                    subtitle: Text('addResearch.isTopTierJournalHint'.tr()),
                    value: _isTopTierJournal,
                    onChanged: (bool value) =>
                        setState(() => _isTopTierJournal = value),
                    activeThumbColor: Colors.blue,
                  ),
                  SizedBox(height: 12.h),

                  TextFormField(
                    controller: _journalUrlController,
                    decoration: InputDecoration(
                      labelText: 'addResearch.journalUrl'.tr(),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? 'validation.required'.tr() : null,
                  ),
                  SizedBox(height: 20.h),

                  _buildCertifiedReportSection(),
                  SizedBox(height: 20.h),

                  FilePickerField(
                    label: 'addResearch.paperFile'.tr(),
                    selectedFile: _paperFile,
                    onFileSelected: (file) => setState(() => _paperFile = file),
                    isRequired: true,
                  ),
                  SizedBox(height: 12.h),

                  FilePickerField(
                    label: _selectedIndexDatabase == IndexingDatabase.other
                        ? 'addResearch.indexingProof'.tr()
                        : '${'addResearch.indexingProofLabelDynamic'.tr()} (${_getDbName(_selectedIndexDatabase)}) - ${'common.required'.tr()}',
                    selectedFile: _indexingProofFile,
                    onFileSelected: (file) =>
                        setState(() => _indexingProofFile = file),
                    isRequired:
                        _selectedIndexDatabase != IndexingDatabase.other,
                  ),
                  SizedBox(height: 30.h),

                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'addResearch.submit'.tr(),
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

  Widget _buildLocalCriteriaSection() {
    final criteriaKeys = [
      "localJournalCriteria.criteria1",
      "localJournalCriteria.criteria2",
      "localJournalCriteria.criteria3",
      "localJournalCriteria.criteria4",
      "localJournalCriteria.criteria5",
      "localJournalCriteria.criteria6",
      "localJournalCriteria.criteria7",
      "localJournalCriteria.criteria8",
    ];

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'addResearch.localCriteria'.tr(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
          ),
          SizedBox(height: 8.h),
          // ✅ إضافة .tr() للنصوص داخل الـ Checkbox
          ...criteriaKeys.map(
            (criterion) => CheckboxListTile(
              dense: true,
              title: Text(criterion.tr(), style: TextStyle(fontSize: 13.sp)),
              value: _localCriteria[criterion] ?? false,
              onChanged: (val) => setState(() {
                _localCriteria[criterion] = val ?? false;
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertifiedReportSection() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_outlined, color: Colors.blue, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'addResearch.certifiedReportTitle'.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          TextFormField(
            controller: _reportNumberController,
            decoration: InputDecoration(
              labelText: 'addResearch.reportNumber'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          SizedBox(height: 12.h),
          // ✅ استخدام مفتاح الترجمة الصحيح
          FilePickerField(
            label: 'filePicker.selectReport'.tr(),
            selectedFile: _certifiedReportFile,
            onFileSelected: (file) =>
                setState(() => _certifiedReportFile = file),
            isRequired: false,
          ),
        ],
      ),
    );
  }
}
