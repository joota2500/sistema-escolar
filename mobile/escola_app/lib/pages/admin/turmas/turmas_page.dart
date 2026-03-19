import 'package:flutter/material.dart';

import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../../models/turma.dart';

import 'criar_turma_page.dart';
import 'editar_turma_page.dart';

class TurmasPage extends StatefulWidget {
  const TurmasPage({super.key});

  @override
  State<TurmasPage> createState() => _TurmasPageState();
}

class _TurmasPageState extends State<TurmasPage> {
  List<Turma> turmas = [];
  bool carregando = true;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    iniciar();
  }

  Future<void> iniciar() async {
    await carregarPermissao();
    await carregarTurmas();
  }

  Future<void> carregarPermissao() async {
    final role = await AuthService.pegarRole();

    if (!mounted) return;

    setState(() {
      isAdmin = role == "admin";
    });
  }

  Future<void> carregarTurmas() async {
    try {
      final data = await ApiService.buscarTurmas();

      if (!mounted) return;

      setState(() {
        turmas = data;
        carregando = false;
      });
    } catch (_) {
      setState(() => carregando = false);
    }
  }

  void semPermissao() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("🚫 Você não tem permissão")));
  }

  Future<void> deletarTurma(String id) async {
    if (!isAdmin) return semPermissao();

    final confirmar = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Excluir Turma"),
        content: const Text("Deseja excluir?"),
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

    await ApiService.deletarTurma(id);
    carregarTurmas();
  }

  Future<void> abrirCriarTurma() async {
    if (!isAdmin) return semPermissao();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CriarTurmaPage()),
    );

    if (result == true) carregarTurmas();
  }

  Future<void> abrirEditarTurma(Turma turma) async {
    if (!isAdmin) return semPermissao();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditarTurmaPage(turma: turma.toJson())),
    );

    if (result == true) carregarTurmas();
  }

  // ==========================
  // 🔗 VINCULAR PROFESSOR (PRÓXIMO PASSO)
  // ==========================
  void vincularProfessor(Turma turma) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Vincular professor na turma: ${turma.nome}")),
    );
  }

  Widget buildCard(Turma turma) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      child: InkWell(
        onTap: () => abrirEditarTurma(turma),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NOME
              Text(
                turma.nome,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              // INFO
              Text("Série: ${turma.serie}"),
              Text("Turno: ${turma.turno.isNotEmpty ? turma.turno : "-"}"),
              Text("Sala: ${turma.sala.isNotEmpty ? turma.sala : "-"}"),

              const SizedBox(height: 10),

              // AÇÕES
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 🔗 VINCULAR PROFESSOR
                  TextButton.icon(
                    onPressed: () => vincularProfessor(turma),
                    icon: const Icon(Icons.link),
                    label: const Text("Professor"),
                  ),

                  // 🗑 DELETE
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: isAdmin ? Colors.red : Colors.grey,
                    ),
                    onPressed: () => deletarTurma(turma.id),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Turmas")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: isAdmin ? Colors.blue : Colors.grey,
        onPressed: abrirCriarTurma,
        child: const Icon(Icons.add),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : turmas.isEmpty
          ? const Center(child: Text("Nenhuma turma cadastrada"))
          : ListView.builder(
              itemCount: turmas.length,
              itemBuilder: (_, i) => buildCard(turmas[i]),
            ),
    );
  }
}
