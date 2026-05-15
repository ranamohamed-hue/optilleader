import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:equatable/equatable.dart';
import 'package:optialeader/feature/doctor/data/model/research_paper_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';
import 'package:optialeader/feature/doctor/data/repo/research_paper/research_paper_repo.dart';
import 'package:optialeader/feature/doctor/logic/research_paper/research_paper_State.dart';


class ResearchCubit extends Cubit<ResearchState> {
  final ResearchRepo researchRepo;

  ResearchCubit(this.researchRepo) : super(ResearchInitial());

  Future<void> addNewResearch(String doctorUid, ResearchPaperModel paper, File imageFile) async {
    emit(ResearchLoading());
    final result = await researchRepo.addResearchPaper(doctorUid, paper, imageFile);
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

  Future<void> approveResearch(String doctorUid, String paperId) async {
    emit(ResearchLoading());
    final result = await researchRepo.updatePaperStatus(
      doctorUid, 
      paperId, 
      VerificationStatus.approved,
    );
    result.fold(
      (error) => emit(ResearchError(error: error)),
      (_) => emit(ResearchSuccess()),
    );
  }

  Future<void> rejectResearch(String doctorUid, String paperId, String reason) async {
    emit(ResearchLoading());
    final result = await researchRepo.updatePaperStatus(
      doctorUid, 
      paperId, 
      VerificationStatus.rejected,
      rejectionReason: reason,
    );
    result.fold(
      (error) => emit(ResearchError(error: error)),
      (_) => emit(ResearchSuccess()),
    );
  }
}