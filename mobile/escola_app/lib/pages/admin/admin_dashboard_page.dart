import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../services/auth_service.dart';
import '../../services/api_service.dart';

import 'escolas/escolas_page.dart';
import 'professores/professores_page.dart';
import 'turmas/turmas_page.dart';
import 'alunos/alunos_page.dart';
import 'relatorios/relatorios_page.dart';

import '../login/login_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  String nome = "";
  String role = "";

  int totalAlunos = 0;
  int totalProfessores = 0;
  int totalTurmas = 0;
  int totalEscolas = 0;

  bool carregando = true;

  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    carregarTudo();
  }

  Future<void> carregarTudo() async {
    await Future.wait([carregarUsuario(), carregarDashboard()]);
    if (!mounted) return;
    setState(() => carregando = false);
  }

  Future<void> carregarUsuario() async {
    final nomeSalvo = await AuthService.pegarNome();
    final roleSalvo = await AuthService.pegarRole();

    if (!mounted) return;

    setState(() {
      nome = nomeSalvo ?? "Administrador";
      role = roleSalvo ?? "admin";
    });
  }

  Future<void> carregarDashboard() async {
    try {
      final alunos = await ApiService.totalAlunos();
      final professores = await ApiService.totalProfessores();
      final turmas = await ApiService.totalTurmas();
      final escolas = await ApiService.totalEscolas();

      if (!mounted) return;

      setState(() {
        totalAlunos = alunos;
        totalProfessores = professores;
        totalTurmas = turmas;
        totalEscolas = escolas;
      });
    } catch (_) {}
  }

  Future<void> logout(BuildContext context) async {
    await AuthService.logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void abrirPagina(BuildContext context, Widget pagina) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => pagina));
  }

  // ==========================
  // DRAWER
  // ==========================
  Widget buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(nome),
            accountEmail: Text(role.toUpperCase()),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                nome.isNotEmpty ? nome[0].toUpperCase() : "A",
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text("Escolas"),
            onTap: () => abrirPagina(context, const EscolasPage()),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Professores"),
            onTap: () => abrirPagina(context, const ProfessoresPage()),
          ),
          ListTile(
            leading: const Icon(Icons.class_),
            title: const Text("Turmas"),
            onTap: () => abrirPagina(context, const TurmasPage()),
          ),
          ListTile(
            leading: const Icon(Icons.groups),
            title: const Text("Alunos"),
            onTap: () => abrirPagina(context, const AlunosPage()),
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text("Relatórios"),
            onTap: () => abrirPagina(context, const RelatoriosPage()),
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Sair"),
            onTap: () async => await logout(context),
          ),
        ],
      ),
    );
  }

  // ==========================
  // GRÁFICO BARRAS
  // ==========================
  Widget graficoResumo() {
    final lista = [totalAlunos, totalProfessores, totalTurmas, totalEscolas];

    final maxValor = lista.isEmpty ? 0 : lista.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (maxValor + 5).toDouble(),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [BarChartRodData(toY: totalAlunos.toDouble())],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [BarChartRodData(toY: totalProfessores.toDouble())],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [BarChartRodData(toY: totalTurmas.toDouble())],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [BarChartRodData(toY: totalEscolas.toDouble())],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================
  // GRÁFICO PIZZA
  // ==========================
  Widget graficoPizza() {
    final total = totalAlunos + totalProfessores + totalTurmas + totalEscolas;

    if (total == 0) {
      return const Center(child: Text("Sem dados"));
    }

    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (event, response) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    response == null ||
                    response.touchedSection == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex = response.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          centerSpaceRadius: 40,
          sections: [
            _secaoPizza(0, totalAlunos, Colors.blue),
            _secaoPizza(1, totalProfessores, Colors.green),
            _secaoPizza(2, totalTurmas, Colors.orange),
            _secaoPizza(3, totalEscolas, Colors.purple),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _secaoPizza(int index, int valor, Color cor) {
    final isTouched = index == touchedIndex;

    return PieChartSectionData(
      color: cor,
      value: valor.toDouble(),
      radius: isTouched ? 60 : 50,
      title: valor.toString(),
      titleStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ==========================
  // CARD
  // ==========================
  Widget cardInfo(String titulo, int valor, IconData icone, Color cor) {
    return Card(
      child: ListTile(
        leading: Icon(icone, color: cor),
        title: Text("$valor"),
        subtitle: Text(titulo),
      ),
    );
  }

  // ==========================
  // UI
  // ==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildDrawer(),
      appBar: AppBar(title: const Text("Painel Administrativo")),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // MÉTRICAS
                  cardInfo("Alunos", totalAlunos, Icons.groups, Colors.blue),
                  cardInfo(
                    "Professores",
                    totalProfessores,
                    Icons.person,
                    Colors.green,
                  ),
                  cardInfo("Turmas", totalTurmas, Icons.class_, Colors.orange),
                  cardInfo(
                    "Escolas",
                    totalEscolas,
                    Icons.school,
                    Colors.purple,
                  ),

                  const SizedBox(height: 20),

                  const Text("Gráfico Geral"),
                  graficoResumo(),

                  const SizedBox(height: 20),

                  const Text("Distribuição"),
                  graficoPizza(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
