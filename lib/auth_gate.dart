// lib/auth_gate.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class AuthGate extends StatelessWidget {
	const AuthGate({super.key});

	@override
	Widget build(BuildContext context) {
		return StreamBuilder<User?>(
			stream: FirebaseAuth.instance.authStateChanges(),
			builder: (context, snapshot) {
				// Se o snapshot ainda não tem dados (carregando)
				if (snapshot.connectionState == ConnectionState.waiting) {
					return const Center(child: CircularProgressIndicator());
				}

				// Se o usuário está logado, mostre a HomeScreen
				if (snapshot.hasData) {
					return const HomeScreen();
				}

				// Se o usuário não está logado, mostre a LoginScreen
				return const LoginScreen();
			},
		);
	}
}