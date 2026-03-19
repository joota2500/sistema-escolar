import 'package:flutter/material.dart';

import '../../../services/api_service.dart';
import '../../../services/professor_service.dart';

class EditarTurmaPage extends StatefulWidget {
  final Map<String, dynamic> turma;

  const EditarTurmaPage({super.key, required this.turma});

  @override
  State<EditarTurmaPage> createState() => _EditarTurmaPageState();
}

class _EditarTurmaPageState extends State<EditarTurmaPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nomeController;
  late TextEditingController serieController;
  late TextEditingController salaController;
  late TextEditingController turnoController;
  late TextEditingController capacidadeController;
  late TextEditingController anoController;

  List<Map<String, dynamic>> escolas = [];
  String? escolaSelecionada;

  // 🔥 NOVO
  List<dynamic> professores = [];
  String? professorSelecionado;
  bool carregandoProfessores = true;

  bool carregando = false;

  @override
  void initState() {
    super.initState();

    nomeController = TextEditingController(text: widget.turma["nome"] ?? "");
    serieController = TextEditingController(
      text: widget.turma["serie"]?.toString() ?? "",
    );
    salaController = TextEditingController(text: widget.turma["sala"] ?? "");
    turnoController = TextEditingController(text: widget.turma["turno"] ?? "");
    capacidadeController = TextEditingController(
      text: widget.turma["capacidade"]?.toString() ?? "",
    );
    anoController = TextEditingController(
      text: widget.turma["ano_letivo"]?.toString() ?? "",
    );

    escolaSelecionada = widget.turma["escola_id"]?.toString();

    carregarEscolas();
    carregarProfessores(); // 🔥 NOVO
  }

  // ==========================
  // 🔄 ESCOLAS
  // ==========================
  Future<void> carregarEscolas() async {
    try {
      final data = await ApiService.buscarEscolas();

      if (!mounted) return;

      setState(() {
        escolas = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // ==========================
  // 🔄 PROFESSORES
  // ==========================
  Future<void> carregarProfessores() async {
    try {
      final data = await ProfessorService.buscar();

      if (!mounted) return;

      setState(() {
        professores = data;
        carregandoProfessores = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        carregandoProfessores = false;
      });
    }
  }

  // ==========================
  // 🔗 VINCULAR PROFESSOR
  // ==========================
  Future<void> vincularProfessor() async {
    if (professorSelecionado == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Selecione um professor")));
      return;
    }

    final result = await ProfessorService.vincularTurma(
      professorId: professorSelecionado!,
      turmaId: widget.turma["id"].toString(),
    );

    if (!mounted) return;

    if (result["erro"] != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result["erro"])));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Professor vinculado com sucesso")),
    );
  }

  // ==========================
  // 💾 SALVAR TURMA
  // ==========================
  Future<void> salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (escolaSelecionada == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Selecione uma escola")));
      return;
    }

    setState(() => carregando = true);

    final result =
        await ApiService.atualizarTurma(widget.turma["id"].toString(), {
          "nome": nomeController.text.trim(),
          "serie": int.parse(serieController.text),
          "sala": salaController.text.trim(),
          "turno": turnoController.text.trim(),
          "capacidade": int.parse(capacidadeController.text),
          "ano_letivo": int.parse(anoController.text),
          "escola_id": escolaSelecionada,
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
      const SnackBar(content: Text("Turma atualizada com sucesso")),
    );

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    nomeController.dispose();
    serieController.dispose();
    salaController.dispose();
    turnoController.dispose();
    capacidadeController.dispose();
    anoController.dispose();
    super.dispose();
  }

  // ==========================
  // 🎨 UI
  // ==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Turma")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ==========================
            // 🔗 VINCULAR PROFESSOR
            // ==========================
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    const Text(
                      "Vincular Professor",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    carregandoProfessores
                        ? const CircularProgressIndicator()
                        : DropdownButtonFormField<String>(
                            initialValue: professorSelecionado,
                            decoration: const InputDecoration(
                              labelText: "Professor",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            items: professores.map((prof) {
                              return DropdownMenuItem<String>(
                                value: prof["id"].toString(),
                                child: Text(prof["nome"] ?? ""),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                professorSelecionado = value;
                              });
                            },
                          ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: vincularProfessor,
                        icon: const Icon(Icons.link),
                        label: const Text("Vincular"),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ==========================
            // FORM TURMA
            // ==========================
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nomeController,
                    decoration: const InputDecoration(
                      labelText: "Nome da Turma",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? "Informe o nome"
                        : null,
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: serieController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Série",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: salaController,
                    decoration: const InputDecoration(
                      labelText: "Sala",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: turnoController,
                    decoration: const InputDecoration(
                      labelText: "Turno",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: capacidadeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Capacidade",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: anoController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Ano Letivo",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  DropdownButtonFormField<String>(
                    initialValue: escolaSelecionada,
                    decoration: const InputDecoration(
                      labelText: "Escola",
                      border: OutlineInputBorder(),
                    ),
                    items: escolas.map((escola) {
                      return DropdownMenuItem<String>(
                        value: escola["id"].toString(),
                        child: Text(escola["nome"] ?? ""),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        escolaSelecionada = value;
                      });
                    },
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: carregando ? null : salvar,
                      child: carregando
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Salvar Alterações"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
