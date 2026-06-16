import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/household_status_repository.dart';
import '../../models/dashboard_models.dart';

// --- EVENTOS ---
abstract class HouseholdStatusEvent {}
class LoadHouseholdStatus extends HouseholdStatusEvent {}

// --- ESTADOS ---
abstract class HouseholdStatusState {}
class HouseholdStatusLoading extends HouseholdStatusState {}
class HouseholdStatusLoaded extends HouseholdStatusState {
  final HouseholdStatusData data;
  HouseholdStatusLoaded(this.data);
}
class HouseholdStatusError extends HouseholdStatusState {
  final String message;
  HouseholdStatusError(this.message);
}

// --- BLOC ---
class HouseholdStatusBloc extends Bloc<HouseholdStatusEvent, HouseholdStatusState> {
  final HouseholdStatusRepository repository;

  HouseholdStatusBloc({required this.repository}) : super(HouseholdStatusLoading()) {
    on<LoadHouseholdStatus>((event, emit) async {
      emit(HouseholdStatusLoading());
      try {
        final data = await repository.getHouseholdStatus();
        emit(HouseholdStatusLoaded(data));
      } catch (e) {
        emit(HouseholdStatusError(e.toString()));
      }
    });
  }
}