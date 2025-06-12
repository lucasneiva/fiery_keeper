// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Dentro da classe _HomeScreenState

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      // Caso de segurança, embora o AuthGate deva impedir isso
      return const Scaffold(
        body: Center(child: Text("Usuário não encontrado.")),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      // AQUI: Estamos ouvindo o documento específico do usuário
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        // 1. Lida com o estado de carregamento e erro
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          // O documento do usuário ainda não existe! Precisamos criá-lo.
          // Você pode chamar uma função aqui para criar o documento inicial.
          return Scaffold(body: Center(child: Text("Criando seu bichinho...")));
        }
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text("Ocorreu um erro!")));
        }

        // 2. Extrai os dados e aplica a lógica de tempo
        var userData = snapshot.data!.data() as Map<String, dynamic>;
        var currentState = _determineCurrentFieryState(userData);

        // 3. Constrói a UI com base no estado atual
        return Scaffold(
          appBar: AppBar(title: Text("Meu Fiery Streak")),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Widget que mostra o SVG correto baseado no 'currentState'
                _buildPetImage(currentState),
                SizedBox(height: 20),
                Text("Streak: ${userData['streakCount'] ?? 0}"),
                SizedBox(height: 40),
                // Botão que só é habilitado se o estado permitir
                ElevatedButton(
                  onPressed: currentState == 'NOT_FED'
                      ? _feedPet
                      : null, // Desabilita se não puder alimentar
                  child: Text("Alimentar o Bichinho"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Funções que também estarão dentro de _HomeScreenState

  // Função para ALIMENTAR o pet
  Future<void> _feedPet() async {
    final user = FirebaseAuth.instance.currentUser!;
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    // Pega o streak atual para incrementar
    final doc = await docRef.get();
    final currentStreak = doc.data()?['streakCount'] ?? 0;

    // Atualiza o documento no Firestore
    await docRef.update({
      'fieryState': 'FED',
      'lastFedTimestamp': Timestamp.now(), // Grava a hora exata da alimentação
      'streakCount': currentStreak + 1,
    });
  }

  // Função para DETERMINAR O ESTADO ATUAL (a parte mais importante!)
  String _determineCurrentFieryState(Map<String, dynamic> userData) {
    final String savedState = userData['fieryState'];
    final Timestamp? lastFed = userData['lastFedTimestamp'];

    if (savedState == 'EGG') {
      return 'EGG'; // Se é um ovo, é sempre um ovo até a primeira alimentação
    }

    if (lastFed == null) {
      // Se não for um ovo mas nunca foi alimentado, algo está errado, volte para ovo.
      // Ou trate como um estado inicial.
      return 'EGG';
    }

    // Lógica de tempo: Checar se a última alimentação foi ontem ou antes
    final lastFedDate = lastFed.toDate();
    final now = DateTime.now();
    final isSameDay =
        now.year == lastFedDate.year &&
        now.month == lastFedDate.month &&
        now.day == lastFedDate.day;

    if (savedState == 'FED' && !isSameDay) {
      // Foi alimentado, mas não hoje -> Estado vira 'NÃO ALIMENTADO'
      // Aqui você poderia até mesmo já atualizar o Firestore.
      return 'NOT_FED';
    }

    if (savedState == 'NOT_FED' && !isSameDay) {
      // Não foi alimentado ontem e o dia virou -> Estado vira 'MORTO'
      // Aqui você atualizaria o streak para 0 no Firestore.
      return 'DEAD';
    }

    // Se nenhuma das lógicas de tempo se aplicou, o estado salvo é o estado atual.
    return savedState;
  }

  // Função para escolher o SVG correto
  Widget _buildPetImage(String state) {
    String svgAssetPath;
    switch (state) {
      case 'EGG':
        svgAssetPath = 'assets/egg.svg';
        break;
      case 'FED':
        svgAssetPath = 'assets/fed.svg';
        break;
      case 'NOT_FED':
        svgAssetPath = 'assets/not_fed.svg';
        break;
      case 'DEAD':
        svgAssetPath = 'assets/dead.svg';
        break;
      default:
        svgAssetPath = 'assets/egg.svg'; // Um padrão seguro
    }
    // Supondo que você use o pacote flutter_svg
    // return SvgPicture.asset(svgAssetPath, height: 200);
    return Text("IMAGEM: $svgAssetPath"); // Placeholder por enquanto
  }
}
