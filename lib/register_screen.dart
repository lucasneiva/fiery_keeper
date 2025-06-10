// lib/register_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
	const RegisterScreen({super.key});

	@override
	State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
	final _emailController = TextEditingController();
	final _passwordController = TextEditingController();
	final _confirmPasswordController = TextEditingController();
	final _formKey = GlobalKey<FormState>();
	bool _isLoading = false;

	Future<void> _signUp() async {
		if (!_formKey.currentState!.validate()) return;

		setState(() {
			_isLoading = true;
		});

		try {
			final userCredential = await FirebaseAuth.instance
					.createUserWithEmailAndPassword(
						email: _emailController.text.trim(),
						password: _passwordController.text.trim(),
					);

			final user = userCredential.user;

			if (user != null) {
				// 2. CRIA O DOCUMENTO NO FIRESTORE!
				await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
					'email': user.email,
					'fieryState': 'EGG',
					'streakCount': 0,
					'lastFedTimestamp': null, // Começa nulo, pois ainda não foi alimentado
				});
			}
			// Após o cadastro, o AuthGate já deve redirecionar para HomeScreen
			// Se quiser mostrar uma mensagem de sucesso antes, pode fazer aqui
			if (mounted && Navigator.canPop(context)) {
				Navigator.of(
					context,
				).pop(); // Volta para LoginScreen, que será substituída por HomeScreen
				ScaffoldMessenger.of(context).showSnackBar(
					const SnackBar(
						content: Text('Cadastro realizado com sucesso!'),
						backgroundColor: Colors.green,
					),
				);
			}
		} on FirebaseAuthException catch (e) {
			String message;
			if (e.code == 'weak-password') {
				message = 'A senha fornecida é muito fraca.';
			} else if (e.code == 'email-already-in-use') {
				message = 'Este e-mail já está em uso.';
			} else if (e.code == 'invalid-email') {
				message = 'O formato do e-mail é inválido.';
			} else {
				message = 'Ocorreu um erro. Tente novamente.';
				print('Erro de cadastro: ${e.code} - ${e.message}');
			}
			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(content: Text(message), backgroundColor: Colors.red),
				);
			}
		} catch (e) {
			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(
						content: Text('Ocorreu um erro inesperado: $e'),
						backgroundColor: Colors.red,
					),
				);
			}
		} finally {
			if (mounted) {
				setState(() {
					_isLoading = false;
				});
			}
		}
	}

	@override
	void dispose() {
		_emailController.dispose();
		_passwordController.dispose();
		_confirmPasswordController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Cadastro - Fiery Streak')),
			body: Center(
				child: SingleChildScrollView(
					padding: const EdgeInsets.all(20.0),
					child: Form(
						key: _formKey,
						child: Column(
							mainAxisAlignment: MainAxisAlignment.center,
							crossAxisAlignment: CrossAxisAlignment.stretch,
							children: <Widget>[
								Text(
									'Crie sua conta',
									style: Theme.of(context).textTheme.headlineSmall,
									textAlign: TextAlign.center,
								),
								const SizedBox(height: 30),
								TextFormField(
									controller: _emailController,
									decoration: const InputDecoration(labelText: 'Email'),
									keyboardType: TextInputType.emailAddress,
									validator: (value) {
										if (value == null || value.isEmpty) {
											return 'Por favor, insira um email';
										}
										if (!value.contains('@')) {
											return 'Email inválido';
										}
										return null;
									},
								),
								const SizedBox(height: 16),
								TextFormField(
									controller: _passwordController,
									decoration: const InputDecoration(labelText: 'Senha'),
									obscureText: true,
									validator: (value) {
										if (value == null || value.isEmpty) {
											return 'Por favor, insira uma senha';
										}
										if (value.length < 6) {
											return 'A senha deve ter no mínimo 6 caracteres';
										}
										return null;
									},
								),
								const SizedBox(height: 16),
								TextFormField(
									controller: _confirmPasswordController,
									decoration: const InputDecoration(
										labelText: 'Confirmar Senha',
									),
									obscureText: true,
									validator: (value) {
										if (value == null || value.isEmpty) {
											return 'Por favor, confirme sua senha';
										}
										if (value != _passwordController.text) {
											return 'As senhas não coincidem';
										}
										return null;
									},
								),
								const SizedBox(height: 24),
								_isLoading
										? const Center(child: CircularProgressIndicator())
										: ElevatedButton(
												onPressed: _signUp,
												child: const Text('Cadastrar'),
											),
								const SizedBox(height: 16),
								TextButton(
									onPressed: () {
										Navigator.of(context).pop(); // Voltar para a tela de Login
									},
									child: const Text('Já tem uma conta? Faça login'),
								),
							],
						),
					),
				),
			),
		);
	}
}
