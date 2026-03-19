import 'package:flutter/material.dart';

import '../../../services/api_service.dart';

class RelatoriosPage extends StatefulWidget {
  const RelatoriosPage({super.key});

  @override
  State<RelatoriosPage> createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<RelatoriosPage> {
  int totalEscolas = 0;
  int totalProfessores = 0;
  int totalTurmas = 0;

  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarRelatorios();
  }

  Future<void> carregarRelatorios() async {
    try {
      final escolas = await ApiService.buscarEscolas();
      final professores = await ApiService.buscarProfessores();
      final turmas = await ApiService.buscarTurmas();

      if (!mounted) return;

      setState(() {
        totalEscolas = escolas.length;
        totalProfessores = professores.length;
        totalTurmas = turmas.length;
        carregando = false;
      });
    } catch (e) {
      setState(() {
        carregando = false;
      });
    }
  }

  Widget cardRelatorio({
    required String titulo,
    required String valor,
    required IconData icone,
    required Color cor,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 40, color: cor),

            const SizedBox(height: 10),

            Text(
              valor,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(
              titulo,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Relatórios do Sistema"),

        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: carregarRelatorios,
          ),
        ],
      ),

      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),

              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,

                children: [
                  cardRelatorio(
                    titulo: "Escolas",
                    valor: totalEscolas.toString(),
                    icone: Icons.school,
                    cor: Colors.blue,
                  ),

                  cardRelatorio(
                    titulo: "Professores",
                    valor: totalProfessores.toString(),
                    icone: Icons.person,
                    cor: Colors.green,
                  ),

                  cardRelatorio(
                    titulo: "Turmas",
                    valor: totalTurmas.toString(),
                    icone: Icons.class_,
                    cor: Colors.orange,
                  ),
                ],
              ),
            ),
    );
  }
}
