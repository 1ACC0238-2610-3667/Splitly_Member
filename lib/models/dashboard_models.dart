
class UserInfo {
  final String email;
  final String personName;

  UserInfo({required this.email, required this.personName});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      email: json['email'] ?? '',
      personName: json['personName'] ?? '',
    );
  }
}

class HouseholdMember {
  final String id;
  final String householdId;
  final int userId;

  HouseholdMember({required this.id, required this.householdId, required this.userId});

  factory HouseholdMember.fromJson(Map<String, dynamic> json) {
    return HouseholdMember(
      id: json['id'],
      householdId: json['householdId'],
      userId: json['userId'] ?? 0,
    );
  }
}

class Contribution {
  final String id;
  final String description; // <--- Nuevo campo
  final DateTime? deadlineForMembers;

  Contribution({required this.id, required this.description, this.deadlineForMembers});
  factory Contribution.fromJson(Map<String, dynamic> json) {
    return Contribution(
      id: json['id'],
      description: json['description'] ?? 'Cuota del Hogar',
      deadlineForMembers: json['deadlineForMembers'] != null
          ? DateTime.tryParse(json['deadlineForMembers'])
          : null,
    );
  }
}

class MemberContribution {
  final String id;
  final String contributionId;
  final double amount;
  final String status;
  final String? payedAt;

  MemberContribution({
    required this.id,
    required this.contributionId,
    required this.amount,
    required this.status,
    this.payedAt,
  });

  factory MemberContribution.fromJson(Map<String, dynamic> json) {
    // Corrección para C#: Si la fecha es el valor mínimo de C# (01/01/0001), la volvemos nula
    String? parsedPayedAt = json['payedAt'];
    if (parsedPayedAt != null && (parsedPayedAt.contains("0001") || parsedPayedAt.isEmpty)) {
      parsedPayedAt = null;
    }

    return MemberContribution(
      id: json['id'],
      contributionId: json['contributionId'],
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] ?? 'Pending',
      payedAt: parsedPayedAt,
    );
  }
}

// --- MODELOS PARA LA VISTA "DASHBOARD PRINCIPAL" ---

// Datos procesados listos para la UI del Dashboard
class DashboardData {
  final String displayName;
  final String householdId;
  final double totalDebt;
  final double paidDebt;
  final double pendingDebt;
  final int overdueCount;
  final int next7DaysCount;
  final double progressPercentage;

  DashboardData({
    required this.displayName,
    required this.householdId,
    required this.totalDebt,
    required this.paidDebt,
    required this.pendingDebt,
    required this.overdueCount,
    required this.next7DaysCount,
    required this.progressPercentage,
  });
}

// --- MODELOS PARA LA VISTA "MIS CUOTAS" ---

class UserIncome {
  final String? id;
  final double income;

  UserIncome({this.id, required this.income});

  factory UserIncome.fromJson(Map<String, dynamic> json) {
    return UserIncome(
      id: json['id'],
      income: (json['income'] as num).toDouble(),
    );
  }
}

class QuotaItem {
  final String id;
  final String description;
  final double amount;
  final String status;
  final DateTime? deadline;
  final String? payedAt;

  QuotaItem({
    required this.id,
    required this.description,
    required this.amount,
    required this.status,
    this.deadline,
    this.payedAt,
  });
}

// --- MODELOS PARA LA VISTA "ESTADO DEL HOGAR" ---

class HouseholdMemberDetail {
  final String memberName;
  final double paidAmount;
  final double assignedAmount;
  final DateTime? deadline;
  final String status;

  HouseholdMemberDetail({
    required this.memberName,
    required this.paidAmount,
    required this.assignedAmount,
    this.deadline,
    required this.status,
  });
}

class HouseholdStatusData {
  final double totalPaid;
  final double monthlyGoal;
  final int fulfillmentPercentage;
  final int contributorsCount;
  final List<HouseholdMemberDetail> details;

  HouseholdStatusData({
    required this.totalPaid,
    required this.monthlyGoal,
    required this.fulfillmentPercentage,
    required this.contributorsCount,
    required this.details,
  });
}