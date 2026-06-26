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

  // ==========================================
  // 1. بيانات التعريف والتوثيق الأساسية
  // ==========================================
  final _titleArController = TextEditingController();
  final _titleEnController = TextEditingController();
  final _journalNameController = TextEditingController();
  final _issnController = TextEditingController();
  final _publicationYearController = TextEditingController();
  final _journalUrlController = TextEditingController();

  // ==========================================
  // 2. بيانات المحرك الحسابي (المؤثرة على النقاط)
  // ==========================================
  final _authorOrderController = TextEditingController();
  final _totalAuthorsController = TextEditingController();
  final _authorsInSameSpecialtyController = TextEditingController();
  final _reportNumberController = TextEditingController();

  bool _isTopTierJournal = false;

  // ==========================================
  // 3. متغيرات التصنيف
  // ==========================================
  JournalScope _selectedJournalScope = JournalScope.specialized;
  JournalLevel _selectedJournalLevel = JournalLevel.international;
  IndexingDatabase _selectedIndexDatabase = IndexingDatabase.scopus;

  String? _selectedQuartile;

  // ==========================================
  // 4. معايير المجلات المحلية (مربوطة مباشرة بفيلدات الموديل)
  // ==========================================
  bool _peerReviewed = false;
  bool _indexedDatabase = false;
  bool _electronicPublishing = false;
  bool _knownEditorialBoard = false;
  bool _regularPublication = false;
  bool _externalReviewers = false;
  bool _specializedJournal = false;
  bool _externalAuthors = false;

  // ==========================================
  // 5. ملفات الإثبات
  // ==========================================
  PickedFileData? _paperFile;
  PickedFileData? _indexingProofFile;
  PickedFileData? _certifiedReportFile;

  // ==========================================
  // دوال مساعدة
  // ==========================================
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

  /// حساب نقاط المجلة المحلية لحظياً (عشان يظهر للمستخدم)
  double get _computedLocalPoints {
    double score = 0;
    if (_peerReviewed) score += 1;
    if (_indexedDatabase) score += 1;
    if (_electronicPublishing) score += 1;
    if (_knownEditorialBoard) score += 1;
    if (_regularPublication) score += 1;
    if (_externalReviewers) score += 0.5;
    if (_specializedJournal) score += 1;
    if (_externalAuthors) score += 0.5;
    return score;
  }

  void _resetLocalCriteria() {
    _peerReviewed = false;
    _indexedDatabase = false;
    _electronicPublishing = false;
    _knownEditorialBoard = false;
    _regularPublication = false;
    _externalReviewers = false;
    _specializedJournal = false;
    _externalAuthors = false;
  }

  @override
  void dispose() {
    _titleArController.dispose();
    _titleEnController.dispose();
    _journalNameController.dispose();
    _issnController.dispose();
    _publicationYearController.dispose();
    _authorOrderController.dispose();
    _totalAuthorsController.dispose();
    _journalUrlController.dispose();
    _authorsInSameSpecialtyController.dispose();
    _reportNumberController.dispose();
    super.dispose();
  }

  // ==========================================
  // دالة الحفظ والإرسال
  // ==========================================
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
      impactFactor: '',
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
      // ✅ ربط الـ 8 شروط مباشرة بفيلدات الموديل
      peerReviewed: _peerReviewed,
      indexedDatabase: _indexedDatabase,
      electronicPublishing: _electronicPublishing,
      knownEditorialBoard: _knownEditorialBoard,
      regularPublication: _regularPublication,
      externalReviewers: _externalReviewers,
      specializedJournal: _specializedJournal,
      externalAuthors: _externalAuthors,
      certifiedReportNumber: _reportNumberController.text.trim().isEmpty
          ? null
          : _reportNumberController.text.trim(),
      paperFileUrl: '',
      paperFileType:
          _paperFile!.type == UploadedFileType.image ? 'image' : 'pdf',
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

  // ==========================================
  // بناء واجهة المستخدم
  // ==========================================
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
            SnackBar(
                content: Text(state.error), backgroundColor: Colors.red),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. بيانات التعريف
                  _buildBasicInfoFields(),
                  SizedBox(height: 16.h),

                  // 2. قوائم التصنيف (النطاق، المستوى، قاعدة الفهرسة)
                  _buildClassificationDropdowns(),
                  SizedBox(height: 16.h),

                  // 3. حقول ديناميكية حسب قاعدة الفهرسة
                  if (_isInternational) ...[
                    _buildInternationalFields(),
                    SizedBox(height: 16.h),
                  ],
                  if (_isLocal) ...[
                    _buildLocalCriteriaSection(),
                    SizedBox(height: 16.h),
                  ],
                  if (_selectedIndexDatabase == IndexingDatabase.other) ...[
                    _buildIssnField(),
                    SizedBox(height: 16.h),
                  ],

                  // 4. بيانات الإحصاء والترتيب
                  _buildRemainingStatsFields(),
                  SizedBox(height: 16.h),

                  // 5. خيار المجلة المصنفة والرابط
                  _buildTierAndUrlFields(),
                  SizedBox(height: 20.h),

                  // 6. التقرير المعتمد
                  _buildCertifiedReportSection(),
                  SizedBox(height: 20.h),

                  // 7. ملفات الإثبات وزر الحفظ
                  _buildProofFilesSection(isLoading),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // الويدجات الفرعية
  // ==========================================

  /// حقول البيانات الأساسية
  Widget _buildBasicInfoFields() {
    return Column(
      children: [
        TextFormField(
          controller: _titleArController,
          decoration: InputDecoration(labelText: 'addResearch.titleAr'.tr()),
          validator: (v) => v!.isEmpty ? 'validation.required'.tr() : null,
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _titleEnController,
          decoration: InputDecoration(labelText: 'addResearch.titleEn'.tr()),
          validator: (v) => v!.isEmpty ? 'validation.required'.tr() : null,
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _journalNameController,
          decoration:
              InputDecoration(labelText: 'addResearch.journalName'.tr()),
          validator: (v) => v!.isEmpty ? 'validation.required'.tr() : null,
        ),
      ],
    );
  }

  /// قوائم التصنيف الثلاثة
  Widget _buildClassificationDropdowns() {
    return Column(
      children: [
        // النطاق: متخصصة / غير متخصصة
        DropdownButtonFormField<JournalScope>(
          value: _selectedJournalScope,
          decoration: InputDecoration(
            labelText: 'addResearch.journalScopeLabel'.tr(),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
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
          onChanged: (val) => setState(() => _selectedJournalScope = val!),
          validator: (v) => v == null ? 'validation.required'.tr() : null,
        ),
        SizedBox(height: 12.h),

        // المستوى: دولي / إقليمي / محلي
        DropdownButtonFormField<JournalLevel>(
          value: _selectedJournalLevel,
          decoration: InputDecoration(
            labelText: 'addResearch.journalLevelLabel'.tr(),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
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
          onChanged: (val) => setState(() => _selectedJournalLevel = val!),
          validator: (v) => v == null ? 'validation.required'.tr() : null,
        ),
        SizedBox(height: 12.h),

        // قاعدة الفهرسة: سكوبس / ويب أوف ساينس / محلي / أخرى
        DropdownButtonFormField<IndexingDatabase>(
          value: _selectedIndexDatabase,
          decoration: InputDecoration(
            labelText: 'addResearch.indexingDatabaseLabel'.tr(),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
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
            _resetLocalCriteria();
          }),
          validator: (v) => v == null ? 'validation.required'.tr() : null,
        ),
      ],
    );
  }

  /// حقول المجلات الدولية: الربع + الرقم الدولي
  Widget _buildInternationalFields() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.public, color: Colors.deepPurple, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'addResearch.internationalFieldsTitle'.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          DropdownButtonFormField<String>(
            value: _selectedQuartile,
            decoration: InputDecoration(
              labelText: 'addResearch.quartile'.tr(),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              prefixIcon: Icon(Icons.bar_chart, color: Colors.deepPurple),
            ),
            items: ['q1', 'q2', 'q3', 'q4']
                .map((q) => DropdownMenuItem(
                      value: q,
                      child: Text(q.toUpperCase()),
                    ))
                .toList(),
            onChanged: (val) => setState(() => _selectedQuartile = val),
            validator: (v) => v == null ? 'validation.required'.tr() : null,
          ),
          SizedBox(height: 12.h),
          TextFormField(
            controller: _issnController,
            decoration: InputDecoration(
              labelText: 'addResearch.issn'.tr(),
              prefixIcon: Icon(Icons.tag, color: Colors.deepPurple),
            ),
            validator: (v) => v!.isEmpty ? 'validation.required'.tr() : null,
          ),
        ],
      ),
    );
  }

  /// معايير المجلات المحلية: 8 شروط بالإشارة + عرض النقاط لحظياً
  Widget _buildLocalCriteriaSection() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Row(
            children: [
              Icon(Icons.location_city, color: Colors.orange, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'addResearch.localCriteria'.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'addResearch.localCriteriaHint'.tr(),
            style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 8.h),

          // الـ 8 شروط
          _buildCriteriaCheckbox(
            label: 'localJournalCriteria.criteria1'.tr(),
            value: _peerReviewed,
            onChanged: (v) => setState(() => _peerReviewed = v),
            points: 1.0,
          ),
          _buildCriteriaCheckbox(
            label: 'localJournalCriteria.criteria2'.tr(),
            value: _indexedDatabase,
            onChanged: (v) => setState(() => _indexedDatabase = v),
            points: 1.0,
          ),
          _buildCriteriaCheckbox(
            label: 'localJournalCriteria.criteria3'.tr(),
            value: _electronicPublishing,
            onChanged: (v) => setState(() => _electronicPublishing = v),
            points: 1.0,
          ),
          _buildCriteriaCheckbox(
            label: 'localJournalCriteria.criteria4'.tr(),
            value: _knownEditorialBoard,
            onChanged: (v) => setState(() => _knownEditorialBoard = v),
            points: 1.0,
          ),
          _buildCriteriaCheckbox(
            label: 'localJournalCriteria.criteria5'.tr(),
            value: _regularPublication,
            onChanged: (v) => setState(() => _regularPublication = v),
            points: 1.0,
          ),
          _buildCriteriaCheckbox(
            label: 'localJournalCriteria.criteria6'.tr(),
            value: _externalReviewers,
            onChanged: (v) => setState(() => _externalReviewers = v),
            points: 0.5,
          ),
          _buildCriteriaCheckbox(
            label: 'localJournalCriteria.criteria7'.tr(),
            value: _specializedJournal,
            onChanged: (v) => setState(() => _specializedJournal = v),
            points: 1.0,
          ),
          _buildCriteriaCheckbox(
            label: 'localJournalCriteria.criteria8'.tr(),
            value: _externalAuthors,
            onChanged: (v) => setState(() => _externalAuthors = v),
            points: 0.5,
          ),

          // شريط الإجمالي
          Divider(height: 24.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'addResearch.localPointsTotal'.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: _computedLocalPoints > 0
                        ? Colors.orange
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${_computedLocalPoints.toStringAsFixed(1)} / 7.0',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ويدجت واحدة لشرط محلي مع عرض النقاط
  Widget _buildCriteriaCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    required double points,
  }) {
    final pointsLabel = points == 1.0
        ? 'addResearch.onePoint'.tr()
        : 'addResearch.halfPoint'.tr();

    return CheckboxListTile(
      dense: true,
      title: Text(label, style: TextStyle(fontSize: 13.sp)),
      subtitle: Text(
        pointsLabel,
        style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
      ),
      value: value,
      activeColor: Colors.orange,
      contentPadding: EdgeInsets.zero,
      onChanged: (v) => onChanged(v ?? false),
    );
  }

  /// حقل ISSN لو اختار "أخرى"
  Widget _buildIssnField() {
    return TextFormField(
      controller: _issnController,
      decoration: InputDecoration(labelText: 'addResearch.issn'.tr()),
      validator: (v) => v!.isEmpty ? 'validation.required'.tr() : null,
    );
  }

  /// حقول الإحصاء والترتيب
  Widget _buildRemainingStatsFields() {
    return Column(
      children: [
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
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
          keyboardType: TextInputType.number,
          validator: (v) {
            if (v == null || v.isEmpty) return 'validation.required'.tr();
            final sameSpecialty = int.tryParse(v) ?? 0;
            final authorOrder =
                int.tryParse(_authorOrderController.text) ?? 0;
            if (sameSpecialty < authorOrder)
              return 'addResearch.validationAuthorsOrder'.tr();
            return null;
          },
        ),
      ],
    );
  }

  /// خيار المجلة المصنفة ورابط المجلة
  Widget _buildTierAndUrlFields() {
    return Column(
      children: [
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
          decoration: InputDecoration(labelText: 'addResearch.journalUrl'.tr()),
          validator: (v) => v!.isEmpty ? 'validation.required'.tr() : null,
        ),
      ],
    );
  }

  /// قسم التقرير المعتمد
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
                  borderRadius: BorderRadius.circular(8.r)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          SizedBox(height: 12.h),
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

  /// رفع ملفات الإثبات وزر الحفظ
  Widget _buildProofFilesSection(bool isLoading) {
    return Column(
      children: [
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
          isRequired: _selectedIndexDatabase != IndexingDatabase.other,
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
                  borderRadius: BorderRadius.circular(12.r)),
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
    );
  }
}