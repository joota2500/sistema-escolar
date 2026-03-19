import 'package:flutter/material.dart';

import '../../../services/api_service.dart';

class EditarAlunoPage extends StatefulWidget {
  final Map<String, dynamic> aluno;

  const EditarAlunoPage({super.key, required this.aluno});

  @override
  State<EditarAlunoPage> createState() => _EditarAlunoPageState();
}

class _EditarAlunoPageState extends State<EditarAlunoPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nomeController;
  late TextEditingController matriculaController;

  List<Map<String, dynamic>> turmas = [];
  String? turmaSelecionada;

  bool carregando = false;

  @override
  void initState() {
    super.initState();

    nomeController = TextEditingController(text: widget.aluno["nome"] ?? "");

    matriculaController = TextEditingController(
      text: widget.aluno["matricula"] ?? "",
    );

    turmaSelecionada = widget.aluno["turma_id"]?.toString();

    carregarTurmas();
  }

  Future<void> carregarTurmas() async {
    try {
      final data = await ApiService.buscarTurmas();

      if (!mounted) return;

      setState(() {
        turmas = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (turmaSelecionada == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Selecione uma turma")));
      return;
    }

    setState(() {
      carregando = true;
    });

    final result =
        await ApiService.atualizarAluno(widget.aluno["id"].toString(), {
          "nome": nomeController.text.trim(),
          "matricula": matriculaController.text.trim(),
          "turma_id": turmaSelecionada,
        });

    if (!mounted) return;

    setState(() {
      carregando = false;
    });

    if (result["erro"] != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result["erro"])));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Aluno atualizado com sucesso")),
    );

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    nomeController.dispose();
    matriculaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Aluno")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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

              DropdownButtonFormField<String>(
                initialValue: turmaSelecionada,
                decoration: const InputDecoration(
                  labelText: "Turma",
                  prefixIcon: Icon(Icons.class_),
                  border: OutlineInputBorder(),
                ),
                items: turmas.map((turma) {
                  return DropdownMenuItem<String>(
                    value: turma["id"].toString(),
                    child: Text(turma["nome"] ?? ""),
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
                      : const Text("Salvar Alterações"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
