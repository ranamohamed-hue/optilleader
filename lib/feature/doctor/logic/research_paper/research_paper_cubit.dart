import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:optialeader/feature/doctor/data/model/research_paper_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';
import 'package:optialeader/feature/doctor/data/repo/research_paper/research_paper_repo.dart';
import 'package:optialeader/feature/doctor/logic/research_paper/research_paper_state.dart';

class ResearchCubit extends Cubit<ResearchState> {
  final ResearchPaperRepo researchRepo;

  ResearchCubit(this.researchRepo) : super(ResearchInitial());

  Future<void> addNewResearch({
    required String doctorUid,
    required ResearchPaperModel paper,
    required File paperFile,
    File? indexingProofFile,
  }) async {
    emit(ResearchLoading());
    final result = await researchRepo.addResearchPaper(
      doctorUid: doctorUid,
      paper: paper,
      paperFile: paperFile,
      indexingProofFile: indexingProofFile,
    );
    result.fold(
      (error) => emit(ResearchError(error: error)),
      (_) => emit(ResearchSuccess()),
    );
  }

  Future<void> deleteResearch(String doctorUid, String paperId) async {
    emit(ResearchLoading());
    final result = await researchRepo.deleteResearchPaper(doctorUid, paperId);
    result.fold(
      (error) => emit(ResearchError(error: error)),
      (_) => emit(ResearchSuccess()),
    );
  }

  // ✅ [إضافة] الدالة العامة لتغيير الحالة
  Future<void> updatePaperStatus(
    String doctorUid,
    String paperId,
    VerificationStatus status, {
    String? rejectionReason,
  }) async {
    emit(ResearchLoading());
    final result = await researchRepo.updatePaperStatus(
      doctorUid,
      paperId,
      status,
      rejectionReason: rejectionReason,
    );
    result.fold(
      (error) => emit(ResearchError(error: error)),
      (_) => emit(ResearchSuccess()),
    );
  }

  Future<void> approveResearch(String doctorUid, String paperId) async {
    emit(ResearchLoading());
    final result = await researchRepo.updatePaperStatus(
      doctorUid, paperId, VerificationStatus.approved,
    );
    result.fold(
      (error) => emit(ResearchError(error: error)),
      (_) => emit(ResearchSuccess()),
    );
  }

  Future<void> rejectResearch(String doctorUid, String paperId, String reason) async {
    emit(ResearchLoading());
    final result = await researchRepo.updatePaperStatus(
      doctorUid, paperId, VerificationStatus.rejected,
      rejectionReason: reason,
    );
    result.fold(
      (error) => emit(ResearchError(error: error)),
      (_) => emit(ResearchSuccess()),
    );
  }
}