import 'package:flutter/material.dart';

import '../../../services/api_service.dart';
import 'criar_aluno_page.dart';
import 'editar_aluno_page.dart';

class AlunosPage extends StatefulWidget {
  const AlunosPage({super.key});

  @override
  State<AlunosPage> createState() => _AlunosPageState();
}

class _AlunosPageState extends State<AlunosPage> {
  List<Map<String, dynamic>> alunos = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarAlunos();
  }

  Future<void> carregarAlunos() async {
    try {
      final response = await ApiService.buscarAlunos();

      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
        response,
      );

      if (!mounted) return;

      setState(() {
        alunos = data;
        carregando = false;
      });
    } catch (e) {
      setState(() {
        carregando = false;
      });
    }
  }

  Future<void> deletarAluno(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Excluir Aluno"),
          content: const Text("Deseja realmente excluir este aluno?"),
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
        );
      },
    );

    if (confirmar != true) return;

    final result = await ApiService.deletarAluno(id);

    if (!mounted) return;

    if (result["erro"] != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result["erro"])));
    } else {
      carregarAlunos();
    }
  }

  Future<void> abrirCriarAluno() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CriarAlunoPage()),
    );

    if (result == true) {
      carregarAlunos();
    }
  }

  Future<void> abrirEditarAluno(Map<String, dynamic> aluno) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditarAlunoPage(aluno: aluno)),
    );

    if (result == true) {
      carregarAlunos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gerenciar Alunos"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: carregarAlunos,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: abrirCriarAluno,
        child: const Icon(Icons.add),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : alunos.isEmpty
          ? const Center(child: Text("Nenhum aluno cadastrado"))
          : ListView.builder(
              itemCount: alunos.length,
              itemBuilder: (context, index) {
                final aluno = alunos[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(aluno["nome"] ?? ""),
                    subtitle: Text("Matrícula: ${aluno["matricula"] ?? ""}"),
                    onTap: () {
                      abrirEditarAluno(aluno);
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        deletarAluno(aluno["id"].toString());
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
