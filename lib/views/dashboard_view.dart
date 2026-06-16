import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard/dashboard_bloc.dart';
import '../bloc/dashboard/dashboard_event.dart';
import '../bloc/dashboard/dashboard_state.dart';
import '../models/dashboard_models.dart';

class DashboardView extends StatefulWidget {
  final Function(int)? onNavigate;
  const DashboardView({Key? key, this.onNavigate}) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading || state is DashboardInitial) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
            } else if (state is DashboardError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
            } else if (state is DashboardLoaded) {
              final data = state.data;
              return RefreshIndicator(
                onRefresh: () async => context.read<DashboardBloc>().add(LoadDashboardData()),
                color: const Color(0xFF10B981),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hola, ${data.displayName}",
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Hogar: ${data.householdId}",
                        style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 24),

                      _buildHeroCard(data),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(child: _buildUrgencyCard("⚠️", data.overdueCount.toString(), "Facturas vencidas", "Acción requerida", const Color(0xFFEF4444))),
                          const SizedBox(width: 16),
                          Expanded(child: _buildUrgencyCard("📅", data.next7DaysCount.toString(), "Próximos 7 días", "Cuotas próximas", const Color(0xFFF59E0B))),
                        ],
                      ),
                      const SizedBox(height: 32),

                      const Text(
                        "Acciones rápidas",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(child: _buildActionCard(Icons.credit_card, "Mis cuotas", "Ver y pagar", const Color(0xFF6366F1), () {
                            widget.onNavigate?.call(1);
                          })),
                          const SizedBox(width: 16),
                          Expanded(child: _buildActionCard(Icons.home_rounded, "Mi hogar", "Detalles del grupo", const Color(0xFF10B981), () {
                            widget.onNavigate?.call(2);
                          })),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildHeroCard(DashboardData data) {
    int percent = (data.progressPercentage * 100).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Deuda pendiente total", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            "S/ ${data.pendingDebt.toStringAsFixed(2)}",
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Progreso", style: TextStyle(color: Colors.white, fontSize: 12)),
              Text("$percent%", style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: data.progressPercentage,
              minHeight: 6,
              backgroundColor: const Color(0xFF334155),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Pagado S/ ${data.paidDebt.toStringAsFixed(0)} de S/ ${data.totalDebt.toStringAsFixed(0)}",
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyCard(String emoji, String number, String title, String subtitle, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 12),
          Text(number, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}