import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../login/login_page.dart';
import '../home/home_page.dart';
import '../admin/admin_dashboard_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    iniciarSistema();
  }

  Future<void> iniciarSistema() async {
    final token = await AuthService.pegarToken();
    final role = await AuthService.pegarRole();

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      irParaLogin();
      return;
    }

    if (role == "admin") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
      );
      return;
    }

    if (role == "professor") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
      return;
    }

    await AuthService.logout();
    irParaLogin();
  }

  void irParaLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
