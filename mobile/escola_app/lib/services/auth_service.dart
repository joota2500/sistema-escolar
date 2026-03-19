import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _tokenKey = "auth_token";
  static const _roleKey = "auth_role";
  static const _nomeKey = "auth_nome";

  // ==========================
  // SALVAR USUÁRIO
  // ==========================
  static Future<void> salvarUsuario({
    required String token,
    required String role,
    String? nome,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_tokenKey, token);
    await prefs.setString(_roleKey, role);

    if (nome != null && nome.isNotEmpty) {
      await prefs.setString(_nomeKey, nome);
    }
  }

  // ==========================
  // GETTERS
  // ==========================
  static Future<String?> pegarToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> pegarRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  static Future<String?> pegarNome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nomeKey);
  }

  // ==========================
  // 🔐 NOVO → VERIFICAR ROLE
  // ==========================
  static Future<bool> isAdmin() async {
    final role = await pegarRole();
    return role == "admin";
  }

  static Future<bool> isProfessor() async {
    final role = await pegarRole();
    return role == "professor";
  }

  // ==========================
  // LOGIN
  // ==========================
  static Future<bool> estaLogado() async {
    final token = await pegarToken();
    return token != null && token.isNotEmpty;
  }

  // ==========================
  // LOGOUT
  // ==========================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
