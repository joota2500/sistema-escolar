import 'package:flutter/material.dart';

import '../../../services/api_service.dart';
import '../../../services/disciplina_service.dart';
import '../../../components/select_disciplina.dart';

class CriarProfessorPage extends StatefulWidget {
  const CriarProfessorPage({super.key});

  @override
  State<CriarProfessorPage> createState() => _CriarProfessorPageState();
}

class _CriarProfessorPageState extends State<CriarProfessorPage> {
  final _formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final cpfController = TextEditingController();
  final senhaController = TextEditingController();

  List<Map<String, dynamic>> escolas = [];
  List<Map<String, dynamic>> disciplinas = [];

  String? escolaSelecionada;
  String? disciplinaSelecionada;

  bool carregando = false;
  bool carregandoEscolas = true;
  bool carregandoDisciplinas = true;

  @override
  void initState() {
    super.initState();
    carregarEscolas();
    carregarDisciplinas();
  }

  Future<void> carregarEscolas() async {
    final data = await ApiService.buscarEscolas();

    if (!mounted) return;

    setState(() {
      escolas = List<Map<String, dynamic>>.from(data);
      carregandoEscolas = false;
    });
  }

  Future<void> carregarDisciplinas() async {
    final data = await DisciplinaService.listarDisciplinas();

    if (!mounted) return;

    setState(() {
      disciplinas = data;
      carregandoDisciplinas = false;
    });
  }

  Future<void> salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (escolaSelecionada == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Selecione uma escola")));
      return;
    }

    if (disciplinaSelecionada == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Selecione uma disciplina")));
      return;
    }

    setState(() {
      carregando = true;
    });

    final result = await ApiService.criarProfessor({
      "nome": nomeController.text.trim(),
      "cpf": cpfController.text.trim(),
      "senha": senhaController.text.trim(),
      "disciplina": disciplinaSelecionada,
      "escola_id": escolaSelecionada,
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
      const SnackBar(content: Text("Professor cadastrado com sucesso")),
    );

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    nomeController.dispose();
    cpfController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (carregandoEscolas || carregandoDisciplinas) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Cadastrar Professor")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            children: [
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: "Nome",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Informe o nome" : null,
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: cpfController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "CPF",
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Informe o CPF";
                  }
                  if (value.length < 11) {
                    return "CPF inválido";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Senha",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.length < 4
                    ? "Senha muito curta"
                    : null,
              ),

              const SizedBox(height: 15),

              SelectDisciplina(
                disciplinas: disciplinas,
                value: disciplinaSelecionada,
                onChanged: (value) {
                  setState(() {
                    disciplinaSelecionada = value;
                  });
                },
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                initialValue: escolaSelecionada,
                decoration: const InputDecoration(
                  labelText: "Escola",
                  prefixIcon: Icon(Icons.school),
                  border: OutlineInputBorder(),
                ),
                items: escolas.map((escola) {
                  return DropdownMenuItem<String>(
                    value: escola["id"].toString(),
                    child: Text(escola["nome"]),
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

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: carregando ? null : salvar,
                  child: carregando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Cadastrar Professor"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
