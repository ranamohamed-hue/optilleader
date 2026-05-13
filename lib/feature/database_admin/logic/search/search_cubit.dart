import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/database_admin/data/repo/search/search_repo.dart';
import 'package:optialeader/feature/database_admin/logic/search/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepo _searchRepo;

  SearchCubit(this._searchRepo) : super(SearchInitial());

  Future<void> searchUsers({
    required String query,
    required String searchField,
    String? role,
  }) async {
    if (query.trim().isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    final result = await _searchRepo.searchUsers(
      query: query.trim(),
      searchField: searchField,
      role: role,
    );

    result.fold(
      (error) => emit(
        SearchError("ERROR_SEARCH_FAILED"),
      ), // ✅ إرسال كود خطأ بدل النص العربي
      (users) =>
          emit(SearchSuccess(users)), // ✅ إرجاع القائمة حتى لو كانت فارغة
    );
  }
}
