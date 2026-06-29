import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../utils/translations.dart';
import 'dashboard_view.dart';
import 'quotas_view.dart';
import 'household_status_view.dart';
import 'settings_view.dart';
import 'sign_in_view.dart';

class MainLayoutView extends StatefulWidget {
  const MainLayoutView({Key? key}) : super(key: key);

  @override
  _MainLayoutViewState createState() => _MainLayoutViewState();
}

class _MainLayoutViewState extends State<MainLayoutView> {
  int _currentIndex = 0;

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOut) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const SignInView()),
                (route) => false,
          );
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            DashboardView(),
            QuotasView(),
            HouseholdStatusView(),
            SettingsView(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black45 : Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _changeTab,
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            selectedItemColor: isDark ? const Color(0xFF6366F1) : const Color(0xFF0F172A),
            unselectedItemColor: isDark ? Colors.white54 : const Color(0xFF94A3B8),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.dashboard_rounded),
                label: context.tr('dashboard_tab'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.credit_card_rounded),
                label: context.tr('quotas_tab'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.house_rounded),
                label: context.tr('household_tab'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings_rounded),
                label: context.tr('settings_tab'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}