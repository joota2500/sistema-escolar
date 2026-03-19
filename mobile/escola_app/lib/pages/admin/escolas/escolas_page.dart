import 'package:flutter/material.dart';

import '../../../services/api_service.dart';
import 'criar_escola_page.dart';
import 'editar_escola_page.dart';

class EscolasPage extends StatefulWidget {
  const EscolasPage({super.key});

  @override
  State<EscolasPage> createState() => _EscolasPageState();
}

class _EscolasPageState extends State<EscolasPage> {
  List<Map<String, dynamic>> escolas = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarEscolas();
  }

  // =============================
  // CARREGAR ESCOLAS
  // =============================

  Future<void> carregarEscolas() async {
    setState(() {
      carregando = true;
    });

    try {
      final data = await ApiService.buscarEscolas();

      if (!mounted) return;

      final lista = data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      setState(() {
        escolas = lista;
        carregando = false;
      });
    } catch (e) {
      setState(() {
        carregando = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Erro ao carregar escolas")));
    }
  }

  // =============================
  // DELETAR ESCOLA
  // =============================

  Future<void> deletarEscola(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Excluir Escola"),
          content: const Text("Deseja realmente excluir esta escola?"),
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

    final result = await ApiService.deletarEscola(id);

    if (!mounted) return;

    if (result["erro"] != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result["erro"])));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Escola removida com sucesso")),
    );

    carregarEscolas();
  }

  // =============================
  // ABRIR CRIAR
  // =============================

  Future<void> abrirCriarEscola() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CriarEscolaPage()),
    );

    if (result == true) {
      carregarEscolas();
    }
  }

  // =============================
  // ABRIR EDITAR
  // =============================

  Future<void> abrirEditarEscola(Map<String, dynamic> escola) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditarEscolaPage(escola: escola)),
    );

    if (result == true) {
      carregarEscolas();
    }
  }

  // =============================
  // UI
  // =============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gerenciar Escolas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: carregarEscolas,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: abrirCriarEscola,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: carregarEscolas,
        child: carregando
            ? const Center(child: CircularProgressIndicator())
            : escolas.isEmpty
            ? const Center(
                child: Text(
                  "Nenhuma escola cadastrada",
                  style: TextStyle(fontSize: 16),
                ),
              )
            : ListView.builder(
                itemCount: escolas.length,
                itemBuilder: (context, index) {
                  final escola = escolas[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.school, color: Colors.blue),
                      title: Text(
                        escola["nome"] ?? "",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${escola["cidade"] ?? ""} - ${escola["estado"] ?? ""}",
                          ),
                          Text("Tipo: ${escola["tipo"] ?? ""}"),
                        ],
                      ),
                      onTap: () {
                        abrirEditarEscola(escola);
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          final id = escola["id"];
                          if (id != null) {
                            deletarEscola(id);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
