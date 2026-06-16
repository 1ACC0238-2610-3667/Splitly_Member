import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/settings_repository.dart';

abstract class SettingsEvent {}
class LoadSettings extends SettingsEvent {}
class UpdateSettingToggle extends SettingsEvent {
  final String? language;
  final bool? darkMode;
  final bool? notificationEnabled;
  UpdateSettingToggle({this.language, this.darkMode, this.notificationEnabled});
}

abstract class SettingsState {}
class SettingsLoading extends SettingsState {}
class SettingsLoaded extends SettingsState {
  final SettingsData data;
  SettingsLoaded(this.data);
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository repository;

  SettingsBloc({required this.repository}) : super(SettingsLoading()) {
    on<LoadSettings>((event, emit) async {
      try {
        final data = await repository.getOrCreateSettings();
        emit(SettingsLoaded(data));
      } catch (_) {}
    });

    on<UpdateSettingToggle>((event, emit) async {
      if (state is SettingsLoaded) {
        final current = (state as SettingsLoaded).data;
        try {
          await repository.updateSettings(
            current.id,
            event.language ?? current.language,
            event.darkMode ?? current.darkMode,
            event.notificationEnabled ?? current.notificationEnabled,
          );
          add(LoadSettings());
        } catch (_) {}
      }
    });
  }
}