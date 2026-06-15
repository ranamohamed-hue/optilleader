import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/judge/data/model/interview_scoring_model.dart';
import 'package:optialeader/feature/admin/logic/nomination_request_logic/nomination_request_cubit.dart';
import 'package:optialeader/feature/admin/logic/nomination_request_logic/nomonation_request_state.dart';

class InterviewEvaluationScreen extends StatefulWidget {
  final String requestId;

  const InterviewEvaluationScreen({
    super.key,
    required this.requestId,
  });

  @override
  State<InterviewEvaluationScreen> createState() =>
      _InterviewEvaluationScreenState();
}

class _InterviewEvaluationScreenState extends State<InterviewEvaluationScreen> {
  final TextEditingController _personalController = TextEditingController();
  final TextEditingController _scientificController = TextEditingController();
  final TextEditingController _communicationController =
      TextEditingController();
  final TextEditingController _leadershipController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _selectedInterviewDate;

  final Map<String, double> _maxScores = {
    'personal': 15,
    'scientific': 40,
    'communication': 25,
    'leadership': 20,
  };

  @override
  void dispose() {
    _personalController.dispose();
    _scientificController.dispose();
    _communicationController.dispose();
    _leadershipController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedInterviewDate = picked);
    }
  }

  double _parseDouble(String value) {
    try {
      return double.parse(value);
    } catch (e) {
      return 0.0;
    }
  }

  double get _currentTotal {
    return _parseDouble(_personalController.text) +
        _parseDouble(_scientificController.text) +
        _parseDouble(_communicationController.text) +
        _parseDouble(_leadershipController.text);
  }

  void _submitEvaluation({bool isDraft = false}) {
    if (_selectedInterviewDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('evaluation.interview_date.required'.tr())),
      );
      return;
    }

    final model = InterviewScoringModel(
      interviewDate: _selectedInterviewDate!,
      personalScore: _parseDouble(_personalController.text),
      scientificScore: _parseDouble(_scientificController.text),
      communicationScore: _parseDouble(_communicationController.text),
      leadershipScore: _parseDouble(_leadershipController.text),
      notes: _notesController.text,
      isDraft: isDraft,
    );

    if (!model.isValid && !isDraft) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('evaluation.errors.invalid_scores'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<NominationRequestCubit>().submitInterviewEvaluation(
      requestId: widget.requestId,
      evaluationModel: model,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('evaluation.title'.tr()),
        backgroundColor: colorScheme.primary,
        centerTitle: true,
      ),
      body: BlocListener<NominationRequestCubit, NominationRequestState>(
        listener: (context, state) {
          if (state is NominationRequestLoading) {
            // Optional: Show loading overlay
          }
          
          if (state is NominationRequestActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message.tr()),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
          
          if (state is NominationRequestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateCard(colorScheme),
              SizedBox(height: 20.h),
              _buildScoreCard(
                titleKey: 'evaluation.sections.personal',
                maxScore: _maxScores['personal']!,
                controller: _personalController,
                color: Colors.blue,
              ),
              SizedBox(height: 15.h),
              _buildScoreCard(
                titleKey: 'evaluation.sections.scientific',
                maxScore: _maxScores['scientific']!,
                controller: _scientificController,
                color: Colors.green,
              ),
              SizedBox(height: 15.h),
              _buildScoreCard(
                titleKey: 'evaluation.sections.communication',
                maxScore: _maxScores['communication']!,
                controller: _communicationController,
                color: Colors.orange,
              ),
              SizedBox(height: 15.h),
              _buildScoreCard(
                titleKey: 'evaluation.sections.leadership',
                maxScore: _maxScores['leadership']!,
                controller: _leadershipController,
                color: Colors.purple,
              ),
              SizedBox(height: 20.h),
              _buildTotalCard(colorScheme),
              SizedBox(height: 20.h),
              _buildNotesCard(colorScheme),
              SizedBox(height: 40.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _submitEvaluation(isDraft: true),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colorScheme.primary),
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                      ),
                      child: Text('evaluation.actions.save_draft'.tr()),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => _submitEvaluation(isDraft: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                      ),
                      child: Text(
                        'evaluation.actions.approve'.tr(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateCard(ColorScheme colorScheme) {
    return InkWell(
      onTap: _pickDate,
      child: Container(
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedInterviewDate == null
                  ? 'evaluation.interview_date.hint'.tr()
                  : DateFormat('yyyy-MM-dd').format(_selectedInterviewDate!),
              style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            ),
            Icon(Icons.calendar_today, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard({
    required String titleKey,
    required double maxScore,
    required TextEditingController controller,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
        ],
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.star, color: color, size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  titleKey.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'evaluation.criteria.input_score'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 15.w),
              Text(
                'evaluation.criteria.max_score'.tr(args: ['$maxScore']),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.primary),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'evaluation.criteria.total_score'.tr(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
          ),
          Text(
            '${_currentTotal.toStringAsFixed(1)} / 100',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'evaluation.notes.title'.tr(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
        ),
        SizedBox(height: 10.h),
        TextField(
          controller: _notesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'evaluation.notes.hint'.tr(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }
}