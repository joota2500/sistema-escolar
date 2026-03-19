import 'package:flutter/material.dart';

import '../../../services/api_service.dart';
import '../../../components/select_estado.dart';
import '../../../components/select_cidade.dart';

class CriarEscolaPage extends StatefulWidget {
  const CriarEscolaPage({super.key});

  @override
  State<CriarEscolaPage> createState() => _CriarEscolaPageState();
}

class _CriarEscolaPageState extends State<CriarEscolaPage> {
  final _formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final cnpjController = TextEditingController();
  final telefoneController = TextEditingController();
  final emailController = TextEditingController();

  final diretorNomeController = TextEditingController();
  final diretorEmailController = TextEditingController();
  final diretorTelefoneController = TextEditingController();

  String? estado;
  String? cidade;
  String? tipo;

  bool carregando = false;

  Future<void> salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (estado == null || cidade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione estado e cidade")),
      );
      return;
    }

    setState(() {
      carregando = true;
    });

    final result = await ApiService.criarEscola({
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
      const SnackBar(content: Text("Escola cadastrada com sucesso")),
    );

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    nomeController.dispose();
    cnpjController.dispose();
    telefoneController.dispose();
    emailController.dispose();
    diretorNomeController.dispose();
    diretorEmailController.dispose();
    diretorTelefoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastrar Escola")),
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
                validator: (v) =>
                    v == null || v.isEmpty ? "Informe o CNPJ" : null,
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Tipo de escola",
                  border: OutlineInputBorder(),
                ),
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
                validator: (v) =>
                    v == null ? "Selecione o tipo da escola" : null,
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
                  labelText: "Email da escola",
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
                      : const Text("Salvar Escola"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
