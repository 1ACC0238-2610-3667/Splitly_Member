abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String message;
  AuthSuccess({required this.message});
}

class AuthSignInSuccess extends AuthState {
  final String householdId;
  AuthSignInSuccess({required this.householdId});
}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure({required this.error});
}

class AuthLoggedOut extends AuthState {}