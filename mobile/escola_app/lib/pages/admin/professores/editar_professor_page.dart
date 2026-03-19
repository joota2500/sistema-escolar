import 'package:flutter/material.dart';

import '../../../services/api_service.dart';

class EditarProfessorPage extends StatefulWidget {
  final Map<String, dynamic> professor;

  const EditarProfessorPage({super.key, required this.professor});

  @override
  State<EditarProfessorPage> createState() => _EditarProfessorPageState();
}

class _EditarProfessorPageState extends State<EditarProfessorPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nomeController;
  late TextEditingController disciplinaController;

  String status = "ativo";

  bool carregando = false;

  @override
  void initState() {
    super.initState();

    nomeController = TextEditingController(
      text: widget.professor["nome"] ?? "",
    );

    disciplinaController = TextEditingController(
      text: widget.professor["disciplina"] ?? "",
    );

    status = widget.professor["status"] ?? "ativo";
  }

  Future<void> salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      carregando = true;
    });

    final result =
        await ApiService.atualizarProfessor(widget.professor["id"].toString(), {
          "nome": nomeController.text.trim(),
          "disciplina": disciplinaController.text.trim(),
          "status": status,
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
      const SnackBar(content: Text("Professor atualizado com sucesso")),
    );

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    nomeController.dispose();
    disciplinaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Professor")),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Informe o nome";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: disciplinaController,
                decoration: const InputDecoration(
                  labelText: "Disciplina",
                  prefixIcon: Icon(Icons.menu_book),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(
                  labelText: "Status",
                  prefixIcon: Icon(Icons.verified_user),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "ativo", child: Text("Ativo")),
                  DropdownMenuItem(value: "inativo", child: Text("Inativo")),
                ],
                onChanged: (String? value) {
                  if (value == null) return;

                  setState(() {
                    status = value;
                  });
                },
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
