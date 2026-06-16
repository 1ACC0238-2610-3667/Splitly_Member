import 'dart:convert';
import 'package:http/http.dart' as http;
import '../db/local_database.dart';
import '../models/dashboard_models.dart';

class HouseholdStatusRepository {
  static const String baseUrl = "http://192.168.1.31:5070/api/v1";
  final LocalDatabase localDatabase;

  HouseholdStatusRepository({required this.localDatabase});

  Future<HouseholdStatusData> getHouseholdStatus() async {
    final token = await localDatabase.getToken();
    final householdId = await localDatabase.getHouseholdId();

    if (token == null || householdId == null) throw Exception("Sesión no válida");

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final membersRes = await http.get(Uri.parse('$baseUrl/household_member/household/$householdId'), headers: headers);
    final membersRaw = jsonDecode(membersRes.body);
    final membersList = (membersRaw is List ? membersRaw : [membersRaw]).map((e) => HouseholdMember.fromJson(e)).toList();

    final contribRes = await http.get(Uri.parse('$baseUrl/contribution/byhouseholdid/$householdId'), headers: headers);
    List<Contribution> contribList = [];
    if (contribRes.statusCode == 200 && contribRes.body.isNotEmpty) {
      final contribRaw = jsonDecode(contribRes.body);
      contribList = (contribRaw is List ? contribRaw : [contribRaw]).map((e) => Contribution.fromJson(e)).toList();
    }

    final allUsersRes = await http.get(Uri.parse('$baseUrl/user'), headers: headers);
    Map<int, String> userNameMap = {};
    if (allUsersRes.statusCode == 200) {
      final usersRaw = jsonDecode(allUsersRes.body) as List;
      for (var u in usersRaw) {
        int uId = u['id'];
        String pName = u['personName'] ?? '';
        String email = u['email'] ?? '';

        if (pName.isNotEmpty) {
          userNameMap[uId] = pName;
        } else if (email.isNotEmpty && !email.contains("com.split")) {
          userNameMap[uId] = email.split('@')[0];
        } else {
          userNameMap[uId] = "Usuario $uId";
        }
      }
    }

    double globalPaid = 0;
    double globalGoal = 0;
    List<HouseholdMemberDetail> details = [];

    await Future.wait(membersList.map((member) async {
      String memberName = userNameMap[member.userId] ?? "Usuario desconocido";

      final mcRes = await http.get(Uri.parse('$baseUrl/member_contribution/bymemberid/${member.id}'), headers: headers);
      if (mcRes.statusCode == 200 && mcRes.body.isNotEmpty) {
        final mcRaw = jsonDecode(mcRes.body);
        final mcList = (mcRaw is List ? mcRaw : [mcRaw]).map((e) => MemberContribution.fromJson(e)).toList();

        for (var mc in mcList) {
          double assigned = mc.amount;
          bool isPaid = (mc.status.toLowerCase() == 'done' || mc.status.toLowerCase() == 'paid' || mc.status.toLowerCase() == 'approved');
          double paid = isPaid ? mc.amount : 0.0;

          globalGoal += assigned;
          globalPaid += paid;

          DateTime? deadline;
          try {
            deadline = contribList.firstWhere((c) => c.id == mc.contributionId).deadlineForMembers;
          } catch (_) {}

          details.add(HouseholdMemberDetail(
            memberName: memberName,
            paidAmount: paid,
            assignedAmount: assigned,
            deadline: deadline,
            status: mc.status,
          ));
        }
      }
    }));

    details.sort((a, b) => a.status.compareTo(b.status));

    int percentage = globalGoal > 0 ? ((globalPaid / globalGoal) * 100).toInt() : 0;

    return HouseholdStatusData(
      totalPaid: globalPaid,
      monthlyGoal: globalGoal,
      fulfillmentPercentage: percentage,
      contributorsCount: membersList.length,
      details: details,
    );
  }
}