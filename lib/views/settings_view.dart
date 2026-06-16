import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/settings/settings_bloc.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(LoadSettings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text("Ajustes", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.white, foregroundColor: const Color(0xFF1E293B), elevation: 0),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) return const Center(child: CircularProgressIndicator());
          if (state is SettingsLoaded) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text("Preferencias de la App", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildToggleCard(
                  "Modo Oscuro", Icons.dark_mode_rounded, state.data.darkMode,
                      (val) => context.read<SettingsBloc>().add(UpdateSettingToggle(darkMode: val)),
                ),
                _buildToggleCard(
                  "Notificaciones", Icons.notifications_active_rounded, state.data.notificationEnabled,
                      (val) => context.read<SettingsBloc>().add(UpdateSettingToggle(notificationEnabled: val)),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<AuthBloc>().add(LogoutRequested());
                    },
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    label: const Text("Cerrar Sesión", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                )
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildToggleCard(String title, IconData icon, bool value, Function(bool) onChanged) {
    return Card(
      elevation: 0, margin: const EdgeInsets.only(bottom: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        secondary: Icon(icon, color: const Color(0xFF6366F1)), value: value, activeColor: const Color(0xFF10B981), onChanged: onChanged,
      ),
    );
  }
}