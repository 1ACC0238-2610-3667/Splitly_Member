import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/settings/settings_bloc.dart';
import '../utils/translations.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          context.tr('settings'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) return const Center(child: CircularProgressIndicator());
          if (state is SettingsLoaded) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  context.tr('app_preferences'),
                  style: TextStyle(color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                _buildToggleCard(
                  context,
                  context.tr('dark_mode'),
                  Icons.dark_mode_rounded,
                  state.data.darkMode,
                  (val) => context.read<SettingsBloc>().add(UpdateSettingToggle(darkMode: val)),
                ),
                
                _buildToggleCard(
                  context,
                  context.tr('notifications'),
                  Icons.notifications_active_rounded,
                  state.data.notificationEnabled,
                  (val) => context.read<SettingsBloc>().add(UpdateSettingToggle(notificationEnabled: val)),
                ),

                _buildDropdownCard(
                  context,
                  context.tr('language'),
                  Icons.translate_rounded,
                  state.data.language,
                  const [
                    DropdownMenuItem(value: "es", child: Text("Español")),
                    DropdownMenuItem(value: "en", child: Text("English")),
                  ],
                  (val) {
                    if (val != null) {
                      context.read<SettingsBloc>().add(UpdateSettingToggle(language: val));
                    }
                  },
                ),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<AuthBloc>().add(LogoutRequested());
                    },
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    label: Text(
                      context.tr('logout'),
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
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

  Widget _buildToggleCard(
    BuildContext context,
    String title,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
      ),
      color: Theme.of(context).cardColor,
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        secondary: Icon(icon, color: const Color(0xFF6366F1)),
        value: value,
        activeColor: const Color(0xFF10B981),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownCard(
    BuildContext context,
    String title,
    IconData icon,
    String currentValue,
    List<DropdownMenuItem<String>> items,
    Function(String?) onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
      ),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF6366F1)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentValue,
                items: items,
                onChanged: onChanged,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
                dropdownColor: Theme.of(context).cardColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}