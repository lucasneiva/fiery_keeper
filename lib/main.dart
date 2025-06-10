import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth_gate.dart'; // Vamos criar este arquivo

void main() async {
	WidgetsFlutterBinding.ensureInitialized();
	await Firebase.initializeApp(
		options: DefaultFirebaseOptions.currentPlatform,
	);
	runApp(const MyApp());
}

class MyApp extends StatelessWidget {
	const MyApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			debugShowCheckedModeBanner: false, // Mudei para false para produção
			title: 'Fiery Streak',
			theme: ThemeData(
				primarySwatch: Colors.red,
				scaffoldBackgroundColor: Colors.white,
				inputDecorationTheme: InputDecorationTheme( // Estilo para os campos de texto
					border: OutlineInputBorder(
						borderRadius: BorderRadius.circular(8),
					),
				),
				elevatedButtonTheme: ElevatedButtonThemeData( // Estilo para botões
					style: ElevatedButton.styleFrom(
						backgroundColor: Colors.red,
						foregroundColor: Colors.white,
						padding: const EdgeInsets.symmetric(vertical: 12),
						textStyle: const TextStyle(fontSize: 16),
						shape: RoundedRectangleBorder(
							borderRadius: BorderRadius.circular(8),
						),
					),
				),
			),
			home: const AuthGate(), // AQUI: Nosso ponto de entrada para autenticação
		);
	}
}