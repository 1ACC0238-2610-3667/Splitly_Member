import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/household_status/household_status_bloc.dart';
import '../models/dashboard_models.dart';
import '../utils/translations.dart';

class HouseholdStatusView extends StatefulWidget {
  const HouseholdStatusView({Key? key}) : super(key: key);

  @override
  _HouseholdStatusViewState createState() => _HouseholdStatusViewState();
}

class _HouseholdStatusViewState extends State<HouseholdStatusView> {
  @override
  void initState() {
    super.initState();
    context.read<HouseholdStatusBloc>().add(LoadHouseholdStatus());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          context.tr('my_household'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<HouseholdStatusBloc>().add(LoadHouseholdStatus()),
          ),
        ],
      ),
      body: BlocBuilder<HouseholdStatusBloc, HouseholdStatusState>(
        builder: (context, state) {
          if (state is HouseholdStatusLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)));
          } else if (state is HouseholdStatusError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is HouseholdStatusLoaded) {
            return RefreshIndicator(
              onRefresh: () async => context.read<HouseholdStatusBloc>().add(LoadHouseholdStatus()),
              color: const Color(0xFF6366F1),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(context, context.tr('global_status'), Icons.dashboard_rounded),
                    const SizedBox(height: 16),
                    _buildSummaryGrid(context, state.data),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader(context, context.tr('household_members'), Icons.people_rounded),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(context.tr('exporting_report'))),
                            );
                          },
                          icon: const Icon(Icons.download_rounded, size: 16),
                          label: Text(context.tr('report'), style: const TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildMembersList(context, state.data.details),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 20, color: isDark ? Colors.white70 : const Color(0xFF475569)),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryGrid(BuildContext context, HouseholdStatusData data) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildSummaryCard(context, context.tr('contributed'), "S/ ${data.totalPaid.toStringAsFixed(0)}", Icons.payments_rounded, const Color(0xFF10B981)),
        _buildSummaryCard(context, context.tr('goal'), "S/ ${data.monthlyGoal.toStringAsFixed(0)}", Icons.flag_rounded, const Color(0xFF6366F1)),
        _buildSummaryCard(context, context.tr('achievement'), "${data.fulfillmentPercentage}%", Icons.trending_up_rounded, const Color(0xFFF59E0B)),
        _buildSummaryCard(context, context.tr('members'), "${data.contributorsCount}", Icons.group_rounded, const Color(0xFF0EA5E9)),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, String label, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey.shade800 : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList(BuildContext context, List<HouseholdMemberDetail> details) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (details.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.grey.shade800 : const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            const Icon(Icons.person_off_rounded, size: 48, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            Text(
              context.tr('no_members'),
              style: const TextStyle(color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: details.length,
      itemBuilder: (context, index) {
        final member = details[index];

        String statusLower = member.status.toLowerCase();
        bool isPaid = statusLower == 'done' || statusLower == 'paid' || statusLower == 'approved';
        bool isRequested = statusLower.contains('review') || statusLower.contains('request') || statusLower.contains('revisión');

        String statusText = isPaid
            ? context.tr('paid')
            : (isRequested ? context.tr('in_review') : context.tr('pending'));

        Color statusColor = isPaid
            ? const Color(0xFF10B981)
            : (isRequested ? const Color(0xFFF59E0B) : const Color(0xFFEF4444));

        String deadlineTxt = member.deadline != null ? DateFormat('dd/MM/yyyy').format(member.deadline!) : "-";
        String initialLetter = member.memberName.isNotEmpty ? member.memberName.substring(0, 1).toUpperCase() : "?";

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.grey.shade800 : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.1),
                    child: Text(
                      initialLetter,
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.memberName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          context.tr('limit', args: [deadlineTxt]),
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 0.5),
              Row(
                children: [
                  _buildMemberMetric(
                    context,
                    context.tr('assigned'),
                    "S/ ${member.assignedAmount.toStringAsFixed(2)}",
                    Icons.assignment_outlined,
                  ),
                  const SizedBox(width: 24),
                  _buildMemberMetric(
                    context,
                    context.tr('paid'),
                    "S/ ${member.paidAmount.toStringAsFixed(2)}",
                    Icons.check_circle_outline_rounded,
                    isBold: true,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMemberMetric(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool isBold = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
            Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white70 : const Color(0xFF475569),
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ],
    );
  }
}