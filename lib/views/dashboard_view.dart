import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/dashboard/dashboard_bloc.dart';
import '../bloc/dashboard/dashboard_event.dart';
import '../bloc/dashboard/dashboard_state.dart';
import '../models/dashboard_models.dart';
import '../utils/translations.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading || state is DashboardInitial) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)));
            } else if (state is DashboardError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
            } else if (state is DashboardLoaded) {
              final data = state.data;
              return RefreshIndicator(
                onRefresh: () async => context.read<DashboardBloc>().add(LoadDashboardData()),
                color: const Color(0xFF6366F1),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${context.tr('hello')}, ${data.displayName}",
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${context.tr('household')}: ${data.householdId}",
                                  style: TextStyle(fontSize: 14, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                            child: Text(
                              data.displayName.isNotEmpty ? data.displayName.substring(0, 1).toUpperCase() : "?",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      _buildHeroCard(context, data),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildUrgencyCard(
                              context,
                              "⚠️",
                              data.overdueCount.toString(),
                              context.tr('overdue_invoices'),
                              context.tr('action_required'),
                              const Color(0xFFEF4444),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildUrgencyCard(
                              context,
                              "📅",
                              data.next7DaysCount.toString(),
                              context.tr('next_7_days'),
                              context.tr('upcoming_quotas'),
                              const Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      Text(
                        context.tr('recent_quotas'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildRecentQuotasList(context, data.recentQuotas),
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

  Widget _buildHeroCard(BuildContext context, DashboardData data) {
    int percent = (data.progressPercentage * 100).toInt();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: isDark ? Border.all(color: Colors.grey.shade800) : null,
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF0F172A)).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('pending_debt_total'),
            style: TextStyle(color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF94A3B8), fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            "S/ ${data.pendingDebt.toStringAsFixed(2)}",
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('progress'),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Text(
                "$percent%",
                style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold),
              ),
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
            context.tr('paid_amount_summary', args: [
              data.paidDebt.toStringAsFixed(0),
              data.totalDebt.toStringAsFixed(0),
            ]),
            style: TextStyle(color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF94A3B8), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyCard(
    BuildContext context,
    String emoji,
    String number,
    String title,
    String subtitle,
    Color iconColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey.shade800 : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 12),
          Text(
            number,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentQuotasList(BuildContext context, List<QuotaItem> recentQuotas) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (recentQuotas.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.grey.shade800
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          children: [
            const Icon(Icons.check_circle_outline_rounded, size: 48, color: Color(0xFF10B981)),
            const SizedBox(height: 12),
            Text(
              context.tr('no_pending_quotas'),
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF94A3B8), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Column(
      children: recentQuotas.map((quota) {
        String statusLower = quota.status.toLowerCase();
        bool isPaid = (statusLower == 'done' || statusLower == 'paid' || statusLower == 'approved');
        bool isRequested = statusLower.contains('review') || statusLower.contains('request');

        Color statusColor = isPaid
            ? const Color(0xFF10B981)
            : (isRequested ? const Color(0xFFF59E0B) : const Color(0xFFEF4444));

        String statusText = isPaid
            ? context.tr('paid')
            : (isRequested ? context.tr('in_review') : context.tr('pending'));

        IconData statusIcon = isPaid
            ? Icons.check_circle_outline_rounded
            : (isRequested ? Icons.hourglass_empty_rounded : Icons.priority_high_rounded);

        String dateTxt = quota.deadline != null
            ? DateFormat('dd MMM, yyyy').format(quota.deadline!)
            : "-";

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.grey.shade800 : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quota.description,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('due_date', args: [dateTxt]),
                      style: TextStyle(color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF94A3B8), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "S/ ${quota.amount.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}