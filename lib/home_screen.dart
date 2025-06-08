// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiery Streak Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // O AuthGate cuidará de redirecionar para LoginScreen
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bem-vindo!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            if (user != null)
              Text(
                'Logado como: ${user.email}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            const SizedBox(height: 20),
            Text(
              "Firebase is Connected and you are logged in!",
              style: TextStyle(fontSize: 20, color: Colors.green[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}