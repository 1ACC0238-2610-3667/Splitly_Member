import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/quotas_repository.dart';
import '../../models/dashboard_models.dart';

abstract class QuotasEvent {}
class LoadQuotas extends QuotasEvent {}
class SaveIncome extends QuotasEvent {
  final double amount;
  SaveIncome(this.amount);
}
class NotifyPayment extends QuotasEvent {
  final String contributionId;
  final double amount;
  NotifyPayment(this.contributionId, this.amount);
}

abstract class QuotasState {}
class QuotasLoading extends QuotasState {}
class QuotasError extends QuotasState {
  final String message;
  QuotasError(this.message);
}
class QuotasLoaded extends QuotasState {
  final UserIncome? currentIncome;
  final double totalAssigned;
  final double totalPaid;
  final double totalPending;
  final List<QuotaItem> pendingContributions;
  final List<QuotaItem> historyContributions;

  QuotasLoaded({
    this.currentIncome,
    required this.totalAssigned,
    required this.totalPaid,
    required this.totalPending,
    required this.pendingContributions,
    required this.historyContributions,
  });
}

class QuotasBloc extends Bloc<QuotasEvent, QuotasState> {
  final QuotasRepository repository;

  QuotasBloc({required this.repository}) : super(QuotasLoading()) {
    on<LoadQuotas>(_onLoadQuotas);
    on<SaveIncome>(_onSaveIncome);
    on<NotifyPayment>(_onNotifyPayment);
  }

  Future<void> _onLoadQuotas(LoadQuotas event, Emitter<QuotasState> emit) async {
    emit(QuotasLoading());
    try {
      final income = await repository.getUserIncome();
      final allQuotas = await repository.getMyQuotas();

      double assigned = 0;
      double paid = 0;
      List<QuotaItem> pendingList = [];
      List<QuotaItem> historyList = [];

      for (var q in allQuotas) {
        assigned += q.amount;
        String status = q.status.toLowerCase();

        if (status == 'done' || status == 'paid' || status == 'approved') {
          paid += q.amount;
          historyList.add(q);
        } else {
          pendingList.add(q);
        }
      }

      emit(QuotasLoaded(
        currentIncome: income,
        totalAssigned: assigned,
        totalPaid: paid,
        totalPending: assigned - paid,
        pendingContributions: pendingList,
        historyContributions: historyList,
      ));
    } catch (e) {
      emit(QuotasError(e.toString()));
    }
  }

  Future<void> _onSaveIncome(SaveIncome event, Emitter<QuotasState> emit) async {
    if (state is QuotasLoaded) {
      try {
        await repository.saveUserIncome(event.amount);
        add(LoadQuotas());
      } catch (e) {
        emit(QuotasError(e.toString()));
      }
    }
  }

  Future<void> _onNotifyPayment(NotifyPayment event, Emitter<QuotasState> emit) async {
    if (state is QuotasLoaded) {
      try {
        emit(QuotasLoading());
        await repository.requestPaymentApproval(event.contributionId, event.amount);
        add(LoadQuotas());
      } catch (e) {
        emit(QuotasError(e.toString()));
      }
    }
  }
}