import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../db/local_database.dart';
import '../models/dashboard_models.dart';

class QuotasRepository {
  final String baseUrl = dotenv.get('BASE_URL');
  final LocalDatabase localDatabase;

  QuotasRepository({required this.localDatabase});

  Future<UserIncome?> getUserIncome() async {
    final token = await localDatabase.getToken();
    final userId = await localDatabase.getUserId();
    if (token == null || userId == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/user-income/byUserId/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return UserIncome.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<void> saveUserIncome(double amount) async {
    final token = await localDatabase.getToken();
    final userId = await localDatabase.getUserId();
    if (token == null || userId == null) return;

    final existing = await getUserIncome();

    final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
    http.Response response;

    if (existing == null) {
      response = await http.post(
        Uri.parse('$baseUrl/user-income'),
        headers: headers,
        body: jsonEncode({
          "id": "",
          "userId": userId,
          "income": amount
        }),
      );
    } else {
      response = await http.put(
        Uri.parse('$baseUrl/user-income/byId/${existing.id}'),
        headers: headers,
        body: jsonEncode({
          "id": existing.id,
          "income": amount
        }),
      );
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Error al guardar el ingreso: ${response.body}");
    }
  }

  Future<List<QuotaItem>> getMyQuotas() async {
    final token = await localDatabase.getToken();
    final householdId = await localDatabase.getHouseholdId();
    final userId = await localDatabase.getUserId();
    if (token == null || householdId == null || userId == null) throw Exception("Sesión no válida");

    final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};

    final membersRes = await http.get(Uri.parse('$baseUrl/household_member/user/$userId'), headers: headers);
    if (membersRes.statusCode != 200) throw Exception("Error al consultar el miembro del hogar");

    final membersRaw = jsonDecode(membersRes.body);
    final membersList = (membersRaw is List ? membersRaw : [membersRaw]).map((e) => HouseholdMember.fromJson(e)).toList();
    final currentMember = membersList.firstWhere(
          (m) => m.householdId == householdId,
      orElse: () => throw Exception("No estás asignado a este hogar"),
    );

    final mcRes = await http.get(Uri.parse('$baseUrl/member_contribution/bymemberid/${currentMember.id}'), headers: headers);
    List<MemberContribution> mcList = [];
    if (mcRes.statusCode == 200 && mcRes.body.isNotEmpty) {
      final mcRaw = jsonDecode(mcRes.body);
      mcList = (mcRaw is List ? mcRaw : [mcRaw]).map((e) => MemberContribution.fromJson(e)).toList();
    }

    final contribRes = await http.get(Uri.parse('$baseUrl/contribution/byhouseholdid/$householdId'), headers: headers);
    List<Contribution> contribList = [];
    if (contribRes.statusCode == 200 && contribRes.body.isNotEmpty) {
      final contribRaw = jsonDecode(contribRes.body);
      contribList = (contribRaw is List ? contribRaw : [contribRaw]).map((e) => Contribution.fromJson(e)).toList();
    }

    List<QuotaItem> items = [];
    for (var mc in mcList) {
      String description = "Cuota del Hogar";
      DateTime? deadline;

      try {
        final parent = contribList.firstWhere((c) => c.id == mc.contributionId);
        description = parent.description;
        deadline = parent.deadlineForMembers;
      } catch (_) {}

      items.add(QuotaItem(
        id: mc.id,
        description: description,
        amount: mc.amount,
        status: mc.status,
        deadline: deadline,
        payedAt: mc.payedAt,
      ));
    }
    return items;
  }

  Future<void> requestPaymentApproval(String memberContributionId, double amount) async {
    final token = await localDatabase.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/member_contribution/$memberContributionId/request'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({"amount": amount}),
    );

    if (response.statusCode != 200) {
      throw Exception("El servidor rechazó la notificación. Código: ${response.statusCode}");
    }
  }
}