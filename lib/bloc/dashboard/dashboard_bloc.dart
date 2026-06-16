import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repository;

  DashboardBloc({required this.repository}) : super(DashboardInitial()) {
    on<LoadDashboardData>((event, emit) async {
      emit(DashboardLoading());
      try {
        final data = await repository.getDashboardData();
        emit(DashboardLoaded(data));
      } catch (e) {
        emit(DashboardError(e.toString()));
      }
    });
  }
}