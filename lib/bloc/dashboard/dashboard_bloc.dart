import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repository;

  DashboardBloc({required this.repository}) : super(DashboardInitial()) {
    on<LoadDashboardData>((event, emit) async {
      final cached = await repository.getCachedDashboardData();
      if (cached != null) {
        emit(DashboardLoaded(cached));
      } else {
        emit(DashboardLoading());
      }
      try {
        final data = await repository.getDashboardData();
        await repository.saveDashboardDataToCache(data);
        emit(DashboardLoaded(data));
      } catch (e) {
        if (state is! DashboardLoaded) {
          emit(DashboardError(e.toString()));
        }
      } finally {
        event.completer?.complete();
      }
    });
  }
}