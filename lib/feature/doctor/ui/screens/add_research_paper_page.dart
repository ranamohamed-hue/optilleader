import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // ✅ [إضافة]
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';
import 'package:optialeader/core/services/file_halper.dart';
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
  final _publicationYearController = TextEditingController();
  final _journalUrlController = TextEditingController();

  JournalScope _journalScope = JournalScope.specialized;
  JournalLevel _journalLevel = JournalLevel.international;

  PickedFileData? _paperFile;
  PickedFileData? _indexingProofFile;

  @override
  void dispose() {
    _titleArController.dispose();
    _titleEnController.dispose();
    _journalNameController.dispose();
    _issnController.dispose();
    _publicationYearController.dispose();
    _journalUrlController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_paperFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('addResearch.fileRequired'.tr()), backgroundColor: Colors.red), // ✅
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
      publicationYear: int.tryParse(_publicationYearController.text.trim()) ?? 0,
      authorOrder: 1, 
      totalAuthors: 1, 
      journalScope: _journalScope,
      journalLevel: _journalLevel,
      indexingDatabase: IndexingDatabase.scopus,
      journalUrl: _journalUrlController.text.trim(),
      paperFileUrl: '',
      paperFileType: _paperFile!.type == UploadedFileType.image ? 'image' : 'pdf',
      status: VerificationStatus.pending,
    );

    context.read<ResearchCubit>().addNewResearch(
      doctorUid: widget.doctorUid,
      paper: paper,
      paperFile: _paperFile!.file,
      indexingProofFile: _indexingProofFile?.file,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ResearchCubit, ResearchState>(
      listener: (context, state) {
        if (state is ResearchSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('addResearch.success'.tr()), backgroundColor: Colors.green), // ✅
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
          appBar: AppBar(title: Text('addResearch.title'.tr()), centerTitle: true), // ✅
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleArController, 
                    decoration: InputDecoration(labelText: 'addResearch.titleAr'.tr()), // ✅
                    validator: (v) => v!.isEmpty ? 'validation.required'.tr() : null // ✅
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: _titleEnController, 
                    decoration: InputDecoration(labelText: 'addResearch.titleEn'.tr()), // ✅
                    validator: (v) => v!.isEmpty ? 'validation.required'.tr() : null // ✅
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: _journalNameController, 
                    decoration: InputDecoration(labelText: 'addResearch.journalName'.tr()), // ✅
                    validator: (v) => v!.isEmpty ? 'validation.required'.tr() : null // ✅
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _issnController, 
                          decoration: InputDecoration(labelText: 'addResearch.issn'.tr()), // ✅
                          validator: (v) => v!.isEmpty ? 'validation.required'.tr() : null // ✅
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: TextFormField(
                          controller: _publicationYearController, 
                          decoration: InputDecoration(labelText: 'addResearch.publicationYear'.tr()), // ✅
                          keyboardType: TextInputType.number, 
                          validator: (v) => v!.isEmpty ? 'validation.required'.tr() : null // ✅
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: _journalUrlController, 
                    decoration: InputDecoration(labelText: 'addResearch.journalUrl'.tr()), // ✅
                    validator: (v) => v!.isEmpty ? 'validation.required'.tr() : null // ✅
                  ),
                  SizedBox(height: 20.h),
                  
                  // رفع الملفات
                  FilePickerField(
                    label: 'addResearch.paperFile'.tr(), // ✅
                    selectedFile: _paperFile,
                    onFileSelected: (file) => setState(() => _paperFile = file),
                    isRequired: true,
                  ),
                  SizedBox(height: 12.h),
                  FilePickerField(
                    label: 'addResearch.indexingProof'.tr(), // ✅
                    selectedFile: _indexingProofFile,
                    onFileSelected: (file) => setState(() => _indexingProofFile = file),
                  ),
                  SizedBox(height: 30.h),
                  
                  // زرار الإرسال
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, 
                        foregroundColor: Colors.white, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))
                      ),
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('addResearch.submit'.tr(), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)), // ✅
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