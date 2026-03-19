import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../home/home_page.dart';
import '../admin/admin_dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController loginController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  bool carregando = false;
  bool mostrarSenha = false;

  int tapCount = 0;
  bool mostrarSuperAdmin = false;

  // ==========================
  // 💬 MENSAGEM
  // ==========================
  void mostrarMensagem(String texto, {Color cor = Colors.blue}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(texto), backgroundColor: cor));
  }

  // ==========================
  // 🔴 SUPER ADMIN
  // ==========================
  void detectarTapSecreto() {
    tapCount++;

    if (tapCount >= 5) {
      setState(() => mostrarSuperAdmin = true);
      mostrarMensagem("🔐 Modo admin liberado");
      tapCount = 0;
    }
  }

  Future<void> loginSuperAdmin(String login, String senha) async {
    const superLogin = "Joota2500";
    const superSenha = "#Joota05";

    if (login == superLogin && senha == superSenha) {
      await AuthService.salvarUsuario(
        token: "super_admin",
        role: "admin",
        nome: "Super Admin",
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
      );
    } else {
      senhaController.clear();
      mostrarMensagem("❌ Super Admin inválido", cor: Colors.red);
    }
  }

  // ==========================
  // 🔐 ADMIN
  // ==========================
  Future<void> loginAdmin(String email, String senha) async {
    final res = await ApiService.loginAdmin(email, senha);

    if (!mounted) return;

    if (res["erro"] != null) {
      senhaController.clear();
      mostrarMensagem("❌ ${res["erro"]}", cor: Colors.red);
      return;
    }

    final usuario = res["usuario"] ?? {};
    final token = res["access_token"];

    if (token == null) {
      mostrarMensagem("❌ Token não recebido", cor: Colors.red);
      return;
    }

    await AuthService.salvarUsuario(
      token: token,
      role: usuario["role"] ?? "admin",
      nome: usuario["nome"] ?? "Admin",
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
    );
  }

  // ==========================
  // 👨‍🏫 PROFESSOR
  // ==========================
  Future<void> loginProfessor(String cpf, String senha) async {
    final res = await ApiService.loginProfessor(cpf, senha);

    if (!mounted) return;

    if (res["erro"] != null) {
      senhaController.clear();
      mostrarMensagem("❌ ${res["erro"]}", cor: Colors.red);
      return;
    }

    final usuario = res["usuario"] ?? {};
    final token = res["access_token"];

    if (token == null) {
      mostrarMensagem("❌ Token não recebido", cor: Colors.red);
      return;
    }

    await AuthService.salvarUsuario(
      token: token,
      role: usuario["role"] ?? "professor",
      nome: usuario["nome"] ?? "Professor",
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  // ==========================
  // 🚀 LOGIN PRINCIPAL
  // ==========================
  Future<void> fazerLogin() async {
    if (carregando) return;

    final login = loginController.text.trim();
    final senha = senhaController.text.trim();

    if (login.isEmpty || senha.isEmpty) {
      mostrarMensagem("⚠️ Preencha os campos", cor: Colors.orange);
      return;
    }

    setState(() => carregando = true);

    try {
      // SUPER ADMIN
      if (mostrarSuperAdmin && login == "Joota2500") {
        await loginSuperAdmin(login, senha);
      }
      // ADMIN
      else if (login.contains("@")) {
        await loginAdmin(login, senha);
      }
      // PROFESSOR
      else {
        await loginProfessor(login, senha);
      }
    } catch (e) {
      mostrarMensagem("❌ Erro inesperado", cor: Colors.red);
    } finally {
      if (mounted) {
        setState(() => carregando = false);
      }
    }
  }

  @override
  void dispose() {
    loginController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  // ==========================
  // 🎨 UI
  // ==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              GestureDetector(
                onTap: detectarTapSecreto,
                child: const Icon(Icons.school, size: 90, color: Colors.blue),
              ),

              const SizedBox(height: 20),

              const Text(
                "Sistema Escolar",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              const Text(
                "Acesse sua conta",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: loginController,
                decoration: const InputDecoration(
                  hintText: "Email ou CPF",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: senhaController,
                obscureText: !mostrarSenha,
                decoration: InputDecoration(
                  hintText: "Senha",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      mostrarSenha ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => mostrarSenha = !mostrarSenha);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: carregando ? null : fazerLogin,
                  child: carregando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Entrar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
