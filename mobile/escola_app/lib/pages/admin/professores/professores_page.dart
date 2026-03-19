import 'package:flutter/material.dart';

import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';

import 'criar_professor_page.dart';
import 'editar_professor_page.dart';

class ProfessoresPage extends StatefulWidget {
  const ProfessoresPage({super.key});

  @override
  State<ProfessoresPage> createState() => _ProfessoresPageState();
}

class _ProfessoresPageState extends State<ProfessoresPage> {
  List<Map<String, dynamic>> professores = [];
  bool carregando = true;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    iniciar();
  }

  Future<void> iniciar() async {
    await carregarPermissao();
    await carregarProfessores();
  }

  Future<void> carregarPermissao() async {
    final role = await AuthService.pegarRole();

    if (!mounted) return;

    setState(() {
      isAdmin = role == "admin";
    });
  }

  Future<void> carregarProfessores() async {
    try {
      final response = await ApiService.buscarProfessores();

      if (!mounted) return;

      setState(() {
        professores = List<Map<String, dynamic>>.from(response);
        carregando = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() => carregando = false);
    }
  }

  void semPermissao() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("🚫 Você não tem permissão")));
  }

  Future<void> deletarProfessor(String id) async {
    if (!isAdmin) return semPermissao();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Excluir Professor"),
        content: const Text("Deseja realmente excluir?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Excluir"),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final result = await ApiService.deletarProfessor(id);

    if (!mounted) return;

    if (result["erro"] != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result["erro"])));
    } else {
      carregarProfessores();
    }
  }

  Future<void> abrirCriarProfessor() async {
    if (!isAdmin) return semPermissao();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CriarProfessorPage()),
    );

    if (result == true) carregarProfessores();
  }

  Future<void> abrirEditarProfessor(Map<String, dynamic> professor) async {
    if (!isAdmin) return semPermissao();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditarProfessorPage(professor: professor),
      ),
    );

    if (result == true) carregarProfessores();
  }

  // ==========================
  // 🎯 CARD PROFISSIONAL
  // ==========================
  Widget cardProfessor(Map<String, dynamic> professor) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => abrirEditarProfessor(professor),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NOME
              Text(
                professor["nome"] ?? "",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              // DISCIPLINA
              Text("Disciplina: ${professor["disciplina"] ?? "-"}"),

              // EMAIL
              Text("Email: ${professor["email"] ?? "-"}"),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 🔗 FUTURO: TURMAS
                  TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Ver turmas de ${professor["nome"]}"),
                        ),
                      );
                    },
                    icon: const Icon(Icons.class_),
                    label: const Text("Turmas"),
                  ),

                  // 🗑 DELETE
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: isAdmin ? Colors.red : Colors.grey,
                    ),
                    onPressed: () =>
                        deletarProfessor(professor["id"].toString()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================
  // 🎨 UI
  // ==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Professores")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: isAdmin ? Colors.blue : Colors.grey,
        onPressed: abrirCriarProfessor,
        child: const Icon(Icons.add),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : professores.isEmpty
          ? const Center(child: Text("Nenhum professor cadastrado"))
          : RefreshIndicator(
              onRefresh: carregarProfessores,
              child: ListView.builder(
                itemCount: professores.length,
                itemBuilder: (_, i) => cardProfessor(professores[i]),
              ),
            ),
    );
  }
}
