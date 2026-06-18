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
    }

    return DashboardData(
      displayName: displayName,
      householdId: householdId,
      totalDebt: totalDebt,
      paidDebt: paidDebt,
      pendingDebt: totalDebt - paidDebt,
      overdueCount: overdueCount,
      next7DaysCount: next7DaysCount,
      progressPercentage: totalDebt > 0 ? (paidDebt / totalDebt) : 0.0,
    );
  }
}