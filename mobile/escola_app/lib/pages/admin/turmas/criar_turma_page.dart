import 'package:flutter/material.dart';

import '../../../services/api_service.dart';

class CriarTurmaPage extends StatefulWidget {
  const CriarTurmaPage({super.key});

  @override
  State<CriarTurmaPage> createState() => _CriarTurmaPageState();
}

class _CriarTurmaPageState extends State<CriarTurmaPage> {
  final _formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final serieController = TextEditingController();
  final salaController = TextEditingController();
  final turnoController = TextEditingController();
  final capacidadeController = TextEditingController();
  final anoController = TextEditingController();

  List<Map<String, dynamic>> escolas = [];
  String? escolaSelecionada;

  bool carregando = false;
  bool carregandoEscolas = true;

  @override
  void initState() {
    super.initState();
    carregarEscolas();
  }

  // ==========================
  // 🔄 CARREGAR ESCOLAS
  // ==========================
  Future<void> carregarEscolas() async {
    try {
      final data = await ApiService.buscarEscolas();

      if (!mounted) return;

      setState(() {
        escolas = List<Map<String, dynamic>>.from(data);
        carregandoEscolas = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      setState(() {
        carregandoEscolas = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Erro ao carregar escolas")));
    }
  }

  // ==========================
  // 💾 SALVAR
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

    try {
      final result = await ApiService.criarTurma({
        "nome": nomeController.text.trim(),
        "serie": int.tryParse(serieController.text) ?? 0,
        "sala": salaController.text.trim(),
        "turno": turnoController.text.trim(),
        "capacidade": int.tryParse(capacidadeController.text) ?? 0,
        "ano_letivo": int.tryParse(anoController.text) ?? 0,
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Turma criada com sucesso")));

      Navigator.pop(context, true);
    } catch (e) {
      setState(() => carregando = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Erro ao salvar turma")));
    }
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
      appBar: AppBar(title: const Text("Criar Turma")),
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
                  labelText: "Nome da Turma",
                  prefixIcon: Icon(Icons.class_),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Informe o nome" : null,
              ),

              const SizedBox(height: 15),

              // SÉRIE
              TextFormField(
                controller: serieController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Série",
                  prefixIcon: Icon(Icons.school),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Informe a série" : null,
              ),

              const SizedBox(height: 15),

              // SALA
              TextFormField(
                controller: salaController,
                decoration: const InputDecoration(
                  labelText: "Sala",
                  prefixIcon: Icon(Icons.meeting_room),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              // TURNO
              TextFormField(
                controller: turnoController,
                decoration: const InputDecoration(
                  labelText: "Turno",
                  prefixIcon: Icon(Icons.schedule),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              // CAPACIDADE
              TextFormField(
                controller: capacidadeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Capacidade",
                  prefixIcon: Icon(Icons.people),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              // ANO
              TextFormField(
                controller: anoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Ano Letivo",
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              // DROPDOWN ESCOLA
              carregandoEscolas
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
                      initialValue: escolaSelecionada,
                      decoration: const InputDecoration(
                        labelText: "Escola",
                        prefixIcon: Icon(Icons.school),
                        border: OutlineInputBorder(),
                      ),
                      items: escolas.map((escola) {
                        return DropdownMenuItem<String>(
                          value: escola["id"].toString(),
                          child: Text(escola["nome"] ?? "Sem nome"),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          escolaSelecionada = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? "Selecione uma escola" : null,
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
                      : const Text("Criar Turma"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
