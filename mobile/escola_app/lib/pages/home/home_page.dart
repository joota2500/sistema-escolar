import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/turma.dart';

import '../admin/turmas/turmas_page.dart';
import '../login/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Turma> turmas = [];
  bool carregando = true;

  String nome = "";

  // ==========================
  // 🔐 PROTEÇÃO DE ROTA
  // ==========================
  Future<void> verificarAutenticacao() async {
    final token = await AuthService.pegarToken();

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🔒 Sessão expirada. Faça login novamente."),
          backgroundColor: Colors.red,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  // ==========================
  // 🔥 CARREGAR USUÁRIO
  // ==========================
  Future<void> carregarUsuario() async {
    final nomeSalvo = await AuthService.pegarNome();

    if (!mounted) return;

    setState(() {
      nome = nomeSalvo ?? "Professor";
    });
  }

  // ==========================
  // CARREGAR TURMAS
  // ==========================
  Future<void> carregarTurmas() async {
    try {
      final List<Turma> data = await ApiService.buscarTurmas();

      if (!mounted) return;

      setState(() {
        turmas = data;
        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        carregando = false;
      });
    }
  }

  // ==========================
  // INIT
  // ==========================
  @override
  void initState() {
    super.initState();
    verificarAutenticacao();
    carregarUsuario(); // 🔥 NOVO
    carregarTurmas();
  }

  // ==========================
  // 🔐 LOGOUT PROFISSIONAL
  // ==========================
  Future<void> logout() async {
    await AuthService.logout();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("👋 Você saiu do sistema"),
        backgroundColor: Colors.blue,
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  // ==========================
  // CARD TURMA
  // ==========================
  Widget cardTurma(Turma turma) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.class_)),
        title: Text(
          turma.nome,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        subtitle: Text("Série ${turma.serie} • Sala ${turma.sala}"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TurmasPage()),
          );
        },
      ),
    );
  }

  // ==========================
  // UI
  // ==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Minhas Turmas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Atualizar",
            onPressed: carregarTurmas,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Sair",
            onPressed: () async => await logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔥 HEADER PROFISSIONAL
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bem-vindo, $nome 👋",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Área do Professor",
                  style: TextStyle(color: Colors.blue),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Visualize e gerencie suas turmas",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          // LISTA
          Expanded(
            child: RefreshIndicator(
              onRefresh: carregarTurmas,
              child: carregando
                  ? const Center(child: CircularProgressIndicator())
                  : turmas.isEmpty
                  ? const Center(
                      child: Text(
                        "Nenhuma turma encontrada",
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: turmas.length,
                      itemBuilder: (context, index) {
                        final turma = turmas[index];
                        return cardTurma(turma);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
