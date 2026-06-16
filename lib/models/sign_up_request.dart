class SignUpRequest {
  final String email;
  final String password;
  final String name;
  final String role;
  final int plan;
  final String householdId;

  SignUpRequest({
    required this.email,
    required this.password,
    required this.name,
    required this.householdId,
    this.role = "Member",
    this.plan = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "password": password,
      "name": name,
      "role": role,
      "plan": plan,
      "householdId": householdId,
    };
  }
}