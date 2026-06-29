import 'dart:async';

abstract class DashboardEvent {}

class LoadDashboardData extends DashboardEvent {
  final Completer<void>? completer;
  LoadDashboardData({this.completer});
}