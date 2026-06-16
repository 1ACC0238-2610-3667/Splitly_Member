class AuthResponse {
  final int id;
  final String email;
  final String token;
  final String householdId;
  final String role;

  AuthResponse({
    required this.id,
    required this.email,
    required this.token,
    required this.householdId,
    required this.role,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      id: json['id'],
      email: json['email'],
      token: json['token'],
      householdId: json['householdId'] ?? "",
      role: json['role'] ?? "Member",
    );
  }
}