import 'package:flutter/material.dart';

import '../../../services/api_service.dart';
import '../../../components/select_estado.dart';
import '../../../components/select_cidade.dart';

class EditarEscolaPage extends StatefulWidget {
  final Map<String, dynamic> escola;

  const EditarEscolaPage({super.key, required this.escola});

  @override
  State<EditarEscolaPage> createState() => _EditarEscolaPageState();
}

class _EditarEscolaPageState extends State<EditarEscolaPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nomeController;
  late TextEditingController cnpjController;
  late TextEditingController telefoneController;
  late TextEditingController emailController;

  late TextEditingController diretorNomeController;
  late TextEditingController diretorEmailController;
  late TextEditingController diretorTelefoneController;

  String? estado;
  String? cidade;
  String? tipo;

  bool carregando = false;

  @override
  void initState() {
    super.initState();

    final escola = widget.escola;

    nomeController = TextEditingController(text: escola["nome"]);
    cnpjController = TextEditingController(text: escola["cnpj"]);
    telefoneController = TextEditingController(text: escola["telefone"]);
    emailController = TextEditingController(text: escola["email"]);

    diretorNomeController = TextEditingController(text: escola["diretor_nome"]);
    diretorEmailController = TextEditingController(
      text: escola["diretor_email"],
    );
    diretorTelefoneController = TextEditingController(
      text: escola["diretor_telefone"],
    );

    estado = escola["estado"];
    cidade = escola["cidade"];
    tipo = escola["tipo"];
  }

  Future<void> salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      carregando = true;
    });

    final result = await ApiService.atualizarEscola(widget.escola["id"], {
      "nome": nomeController.text,
      "cnpj": cnpjController.text,
      "cidade": cidade,
      "estado": estado,
      "tipo": tipo,
      "telefone": telefoneController.text,
      "email": emailController.text,
      "diretor_nome": diretorNomeController.text,
      "diretor_email": diretorEmailController.text,
      "diretor_telefone": diretorTelefoneController.text,
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
      const SnackBar(content: Text("Escola atualizada com sucesso")),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Escola")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: "Nome da Escola",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Informe o nome" : null,
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: cnpjController,
                decoration: const InputDecoration(
                  labelText: "CNPJ",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                initialValue: tipo,
                items: const [
                  DropdownMenuItem(
                    value: "municipal",
                    child: Text("Municipal"),
                  ),
                  DropdownMenuItem(value: "estadual", child: Text("Estadual")),
                  DropdownMenuItem(value: "privada", child: Text("Privada")),
                ],
                onChanged: (v) {
                  setState(() {
                    tipo = v;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Tipo da escola",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              SelectEstado(
                estadoSelecionado: estado,
                onChanged: (v) {
                  setState(() {
                    estado = v;
                    cidade = null;
                  });
                },
              ),

              const SizedBox(height: 15),

              SelectCidade(
                estado: estado,
                cidadeSelecionada: cidade,
                onChanged: (v) {
                  setState(() {
                    cidade = v;
                  });
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: telefoneController,
                decoration: const InputDecoration(
                  labelText: "Telefone",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              const Divider(),

              const SizedBox(height: 20),

              const Text(
                "Diretor",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: diretorNomeController,
                decoration: const InputDecoration(
                  labelText: "Nome do Diretor",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: diretorEmailController,
                decoration: const InputDecoration(
                  labelText: "Email do Diretor",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: diretorTelefoneController,
                decoration: const InputDecoration(
                  labelText: "Telefone do Diretor",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: carregando ? null : salvar,
                  child: carregando
                      ? const CircularProgressIndicator()
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
