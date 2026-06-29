import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../db/local_database.dart';
import '../models/dashboard_models.dart';

class DashboardRepository {
  final String baseUrl = dotenv.get('BASE_URL');
  final LocalDatabase localDatabase;

  DashboardRepository({required this.localDatabase});

  Future<DashboardData> getDashboardData() async {
    final token = await localDatabase.getToken();
    final householdId = await localDatabase.getHouseholdId();
    final userId = await localDatabase.getUserId();
    final backupEmail = await localDatabase.getEmail();

    if (token == null || householdId == null || userId == null) {
      throw Exception("No hay sesión activa");
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    String displayName = backupEmail ?? "Usuario";
    try {
      final userRes = await http.get(Uri.parse('$baseUrl/user/user/$userId'), headers: headers);
      if (userRes.statusCode == 200 && userRes.body.isNotEmpty) {
        final userData = jsonDecode(userRes.body);
        final pName = userData['personName'] ?? '';
        final email = userData['email'] ?? '';

        if (pName.toString().isNotEmpty) {
          displayName = pName;
        } else if (email.toString().isNotEmpty && !email.toString().contains("com.split.backend")) {
          displayName = email;
        }
      }
    } catch (_) {}

    final membersRes = await http.get(Uri.parse('$baseUrl/household_member/user/$userId'), headers: headers);
    if (membersRes.statusCode != 200) {
      throw Exception("Error al consultar miembros del usuario.");
    }

    final decodedMembers = jsonDecode(membersRes.body);
    List<dynamic> membersRawList = decodedMembers is List ? decodedMembers : [decodedMembers];
    final membersList = membersRawList.map((e) => HouseholdMember.fromJson(e)).toList();

    final currentMember = membersList.firstWhere(
          (m) => m.householdId == householdId,
      orElse: () => throw Exception("Miembro no asociado a este hogar"),
    );

    List<Contribution> contributionsList = [];
    final contributionsRes = await http.get(Uri.parse('$baseUrl/contribution/byhouseholdid/$householdId'), headers: headers);

    if (contributionsRes.statusCode == 200 && contributionsRes.body.isNotEmpty) {
      final decodedContributions = jsonDecode(contributionsRes.body);
      List<dynamic> contribsRawList = decodedContributions is List ? decodedContributions : [decodedContributions];
      contributionsList = contribsRawList.map((e) => Contribution.fromJson(e)).toList();
    }

    List<MemberContribution> memberContributions = [];
    final memberContribRes = await http.get(Uri.parse('$baseUrl/member_contribution/bymemberid/${currentMember.id}'), headers: headers);

    if (memberContribRes.statusCode == 200 && memberContribRes.body.isNotEmpty) {
      final decodedMemberContribs = jsonDecode(memberContribRes.body);
      List<dynamic> memberContribsRawList = [];
      if (decodedMemberContribs != null) {
        memberContribsRawList = decodedMemberContribs is List ? decodedMemberContribs : [decodedMemberContribs];
      }
      memberContributions = memberContribsRawList.map((e) => MemberContribution.fromJson(e)).toList();
    }

    double totalDebt = 0;
    double paidDebt = 0;
    int overdueCount = 0;
    int next7DaysCount = 0;
    final now = DateTime.now();

    List<QuotaItem> recentQuotas = [];

    for (var mc in memberContributions) {
      totalDebt += mc.amount;

      String currentStatus = mc.status.toLowerCase();
      // "done" es el valor real en C# de tu Enum EStatus = 1
      if (currentStatus == 'done' || currentStatus == 'paid' || currentStatus == 'approved') {
        paidDebt += mc.amount;
      } else {
        try {
          final parent = contributionsList.firstWhere((c) => c.id == mc.contributionId);
          if (parent.deadlineForMembers != null) {
            final deadline = parent.deadlineForMembers!;
            if (currentStatus != 'review' && currentStatus != 'requested') {
              if (deadline.isBefore(now)) overdueCount++;
              else if (deadline.difference(now).inDays <= 7) next7DaysCount++;
            }
          }
        } catch (_) {}
      }

      String description = "Cuota del Hogar";
      DateTime? deadline;
      try {
        final parent = contributionsList.firstWhere((c) => c.id == mc.contributionId);
        description = parent.description;
        deadline = parent.deadlineForMembers;
      } catch (_) {}

      recentQuotas.add(QuotaItem(
        id: mc.id,
        description: description,
        amount: mc.amount,
        status: mc.status,
        deadline: deadline,
        payedAt: mc.payedAt,
      ));
    }

    // Sort recentQuotas: pending/review first, sorted by deadline (if deadline is null, push to end)
    recentQuotas.sort((a, b) {
      bool aIsPaid = (a.status.toLowerCase() == 'done' || a.status.toLowerCase() == 'paid' || a.status.toLowerCase() == 'approved');
      bool bIsPaid = (b.status.toLowerCase() == 'done' || b.status.toLowerCase() == 'paid' || b.status.toLowerCase() == 'approved');
      if (aIsPaid != bIsPaid) {
        return aIsPaid ? 1 : -1; // unpaid first
      }
      if (a.deadline == null && b.deadline == null) return 0;
      if (a.deadline == null) return 1;
      if (b.deadline == null) return -1;
      return a.deadline!.compareTo(b.deadline!);
    });

    final top3Quotas = recentQuotas.take(3).toList();

    return DashboardData(
      displayName: displayName,
      householdId: householdId,
      totalDebt: totalDebt,
      paidDebt: paidDebt,
      pendingDebt: totalDebt - paidDebt,
      overdueCount: overdueCount,
      next7DaysCount: next7DaysCount,
      progressPercentage: totalDebt > 0 ? (paidDebt / totalDebt) : 0.0,
      recentQuotas: top3Quotas,
    );
  }
}