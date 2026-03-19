import 'package:flutter/material.dart';

import '../../../services/api_service.dart';
import '../../../models/turma.dart';

class CriarAlunoPage extends StatefulWidget {
  const CriarAlunoPage({super.key});

  @override
  State<CriarAlunoPage> createState() => _CriarAlunoPageState();
}

class _CriarAlunoPageState extends State<CriarAlunoPage> {
  final _formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final matriculaController = TextEditingController();

  List<Turma> turmas = [];
  String? turmaSelecionada;

  bool carregando = false;
  bool carregandoTurmas = true;

  @override
  void initState() {
    super.initState();
    carregarTurmas();
  }

  // ==========================
  // 🔄 CARREGAR TURMAS
  // ==========================
  Future<void> carregarTurmas() async {
    try {
      final data = await ApiService.buscarTurmas();

      if (!mounted) return;

      setState(() {
        turmas = data;
        carregandoTurmas = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      setState(() {
        carregandoTurmas = false;
      });
    }
  }

  // ==========================
  // 💾 SALVAR
  // ==========================
  Future<void> salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (turmaSelecionada == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Selecione uma turma")));
      return;
    }

    setState(() => carregando = true);

    final result = await ApiService.criarAluno({
      "nome": nomeController.text.trim(),
      "matricula": matriculaController.text.trim(),
      "turma_id": turmaSelecionada,
    });

    if (!mounted) return;

    setState(() => carregando = false);

    if (result["erro"] != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result["erro"])));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Aluno cadastrado com sucesso")),
    );

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    nomeController.dispose();
    matriculaController.dispose();
    super.dispose();
  }

  // ==========================
  // 🎨 UI
  // ==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastrar Aluno")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // NOME
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: "Nome do aluno",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Informe o nome" : null,
              ),

              const SizedBox(height: 15),

              // MATRÍCULA
              TextFormField(
                controller: matriculaController,
                decoration: const InputDecoration(
                  labelText: "Matrícula",
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? "Informe a matrícula"
                    : null,
              ),

              const SizedBox(height: 15),

              // DROPDOWN TURMA
              carregandoTurmas
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
                      initialValue: turmaSelecionada, // 🔥 CORRIGIDO
                      decoration: const InputDecoration(
                        labelText: "Turma",
                        prefixIcon: Icon(Icons.class_),
                        border: OutlineInputBorder(),
                      ),
                      items: turmas.map((turma) {
                        return DropdownMenuItem<String>(
                          value: turma.id,
                          child: Text(turma.nome), // 🔥 CORRIGIDO
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          turmaSelecionada = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? "Selecione uma turma" : null,
                    ),

              const SizedBox(height: 30),

              // BOTÃO
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: carregando ? null : salvar,
                  child: carregando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Cadastrar Aluno"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
