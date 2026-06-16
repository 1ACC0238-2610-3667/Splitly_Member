import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'sign_in_view.dart';

class HomeView extends StatelessWidget {
  final String householdId;

  const HomeView({Key? key, required this.householdId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOut) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const SignInView()),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Mi Hogar"),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
            )
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.home, size: 100, color: Colors.blue),
              const SizedBox(height: 20),
              const Text("¡Bienvenido a tu hogar!", style: TextStyle(fontSize: 24)),
              const SizedBox(height: 10),
              Text("ID del Hogar: $householdId", style: const TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}