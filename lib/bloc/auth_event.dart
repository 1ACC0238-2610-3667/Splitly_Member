abstract class AuthEvent {}

class SignUpButtonPressed extends AuthEvent {
  final String name, email, password, householdId;
  SignUpButtonPressed({required this.name, required this.email, required this.password, required this.householdId});
}

class SignInButtonPressed extends AuthEvent {
  final String email, password;
  SignInButtonPressed({required this.email, required this.password});
}

class LogoutRequested extends AuthEvent {}