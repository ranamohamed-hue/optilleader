// nomination_request_state.dart
import 'package:optialeader/feature/admin/data/model/nomination_request_model.dart';

abstract class NominationRequestState {}
class NominationRequestInitial extends NominationRequestState {}
class NominationRequestLoading extends NominationRequestState {}
class NominationRequestLoaded extends NominationRequestState {
  final List<NominationRequestModel> requests;
  NominationRequestLoaded(this.requests);
}
class NominationRequestActionSuccess extends NominationRequestState {
  final String message;
  NominationRequestActionSuccess(this.message);
}
class NominationRequestError extends NominationRequestState {
  final String message;
  NominationRequestError(this.message);
}