import 'package:flutter_bloc/flutter_bloc.dart';
import '../db/local_database.dart';
import '../models/sign_up_request.dart';
import '../models/sign_in_request.dart';
import '../repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final LocalDatabase localDatabase;

  AuthBloc({required this.authRepository, required this.localDatabase}) : super(AuthInitial()) {
    on<SignUpButtonPressed>(_onSignUpButtonPressed);
    on<SignInButtonPressed>(_onSignInButtonPressed);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onSignUpButtonPressed(SignUpButtonPressed event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final request = SignUpRequest(
          name: event.name,
          email: event.email,
          password: event.password,
          householdId: event.householdId
      );
      await authRepository.signUpMember(request);
      emit(AuthSuccess(message: "¡Registro exitoso! Ahora inicia sesión."));
    } catch (error) {
      emit(AuthFailure(error: error.toString()));
    }
  }

  Future<void> _onSignInButtonPressed(SignInButtonPressed event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final request = SignInRequest(email: event.email, password: event.password);
      final response = await authRepository.signIn(request);

      await localDatabase.saveSession(response.token, response.householdId, response.id, event.email);

      emit(AuthSignInSuccess(householdId: response.householdId));
    } catch (error) {
      emit(AuthFailure(error: error.toString()));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await localDatabase.clearSession();
    emit(AuthLoggedOut());
  }
}