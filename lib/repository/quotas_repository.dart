import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../db/local_database.dart';
import '../models/dashboard_models.dart';
import '../utils/http_client.dart';

class QuotasRepository {
  final String baseUrl = dotenv.get('BASE_URL');
  final LocalDatabase localDatabase;
  final SharedHttpClient client = SharedHttpClient();

  QuotasRepository({required this.localDatabase});

  Future<UserIncome?> getCachedIncome() async {
    final jsonStr = await localDatabase.getCachedIncome();
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final decoded = jsonDecode(jsonStr);
      return UserIncome(
        id: decoded['id'],
        income: decoded['income'],
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveIncomeToCache(UserIncome income) async {
    final payload = {
      'id': income.id,
      'income': income.income,
    };
    await localDatabase.saveIncomeCache(jsonEncode(payload));
  }

  Future<List<QuotaItem>?> getCachedQuotas() async {
    final jsonStr = await localDatabase.getCachedQuotas();
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final List decoded = jsonDecode(jsonStr);
      return decoded.map((e) => QuotaItem(
        id: e['id'],
        description: e['description'],
        amount: e['amount'],
        status: e['status'],
        deadline: e['deadline'] != null ? DateTime.tryParse(e['deadline']) : null,
        payedAt: e['payedAt'],
      )).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> saveQuotasToCache(List<QuotaItem> quotas) async {
    final listJson = quotas.map((e) => {
      'id': e.id,
      'description': e.description,
      'amount': e.amount,
      'status': e.status,
      'deadline': e.deadline?.toIso8601String(),
      'payedAt': e.payedAt,
    }).toList();
    await localDatabase.saveQuotasCache(jsonEncode(listJson));
  }

  Future<UserIncome?> getUserIncome() async {
    final token = await localDatabase.getToken();
    final userId = await localDatabase.getUserId();
    final householdId = await localDatabase.getHouseholdId();
    if (token == null || userId == null || householdId == null) return null;

    final response = await client.get(
      Uri.parse('$baseUrl/household_member/user/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final membersRaw = jsonDecode(response.body);
      final membersList = (membersRaw is List ? membersRaw : [membersRaw]).map((e) => HouseholdMember.fromJson(e)).toList();
      try {
        final currentMember = membersList.firstWhere((m) => m.householdId == householdId);
        final income = UserIncome(id: currentMember.id, income: currentMember.income ?? 0.0);
        await saveIncomeToCache(income);
        return income;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> saveUserIncome(double amount) async {
    final token = await localDatabase.getToken();
    final userId = await localDatabase.getUserId();
    final householdId = await localDatabase.getHouseholdId();
    if (token == null || userId == null || householdId == null) return;

    final existing = await getUserIncome();
    if (existing == null) throw Exception("No estás asignado a este hogar");

    final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
    
    final response = await client.put(
      Uri.parse('$baseUrl/household_member/${existing.id}'),
      headers: headers,
      body: jsonEncode({
        "income": amount
      }),
    );

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

    final membersRes = await client.get(Uri.parse('$baseUrl/household_member/user/$userId'), headers: headers);
    if (membersRes.statusCode != 200) throw Exception("Error al consultar el miembro del hogar");

    final membersRaw = jsonDecode(membersRes.body);
    final membersList = (membersRaw is List ? membersRaw : [membersRaw]).map((e) => HouseholdMember.fromJson(e)).toList();
    final currentMember = membersList.firstWhere(
          (m) => m.householdId == householdId,
      orElse: () => throw Exception("No estás asignado a este hogar"),
    );

    final mcRes = await client.get(Uri.parse('$baseUrl/member_contribution/bymemberid/${currentMember.id}'), headers: headers);
    List<MemberContribution> mcList = [];
    if (mcRes.statusCode == 200 && mcRes.body.isNotEmpty) {
      final mcRaw = jsonDecode(mcRes.body);
      mcList = (mcRaw is List ? mcRaw : [mcRaw]).map((e) => MemberContribution.fromJson(e)).toList();
    }

    final contribRes = await client.get(Uri.parse('$baseUrl/contribution/byhouseholdid/$householdId'), headers: headers);
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
    await saveQuotasToCache(items);
    return items;
  }

  Future<void> requestPaymentApproval(String memberContributionId, double amount) async {
    final token = await localDatabase.getToken();
    final response = await client.put(
      Uri.parse('$baseUrl/member_contribution/$memberContributionId/request'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({"amount": amount}),
    );

    if (response.statusCode != 200) {
      throw Exception("El servidor rechazó la notificación. Código: ${response.statusCode}");
    }
  }
}