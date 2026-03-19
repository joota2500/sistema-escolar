// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/turma.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = "http://192.168.0.6:3000";

  // =========================
  // 🔐 HEADER DINÂMICO
  // =========================
  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.pegarToken();

    return {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty && token != "super_admin")
        "Authorization": "Bearer $token",
    };
  }

  // =========================
  // REQUEST PADRÃO
  // =========================
  static Future<Map<String, dynamic>> _request(
    Future<http.Response> request,
  ) async {
    try {
      final response = await request.timeout(const Duration(seconds: 10));

      dynamic data;

      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = {};
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (data is Map<String, dynamic>) return data;
        return {"sucesso": true, "data": data};
      }

      return {
        "erro":
            data["message"] ?? data["erro"] ?? "Erro (${response.statusCode})",
      };
    } catch (e) {
      return {"erro": "Erro de conexão com servidor"};
    }
  }

  // =========================
  // 🔐 LOGIN
  // =========================
  static Future<Map<String, dynamic>> loginAdmin(String email, String senha) {
    return _request(
      http.post(
        Uri.parse("$baseUrl/admin/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "senha": senha}),
      ),
    );
  }

  static Future<Map<String, dynamic>> loginProfessor(String cpf, String senha) {
    return _request(
      http.post(
        Uri.parse("$baseUrl/professor/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"cpf": cpf, "senha": senha}),
      ),
    );
  }

  // =========================
  // 👨‍🏫 PROFESSORES
  // =========================
  static Future<List<dynamic>> buscarProfessores() async {
    final res = await http.get(
      Uri.parse("$baseUrl/professor"),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    return [];
  }

  static Future<Map<String, dynamic>> criarProfessor(
    Map<String, dynamic> dados,
  ) async {
    return _request(
      http.post(
        Uri.parse("$baseUrl/professor"),
        headers: await _headers(),
        body: jsonEncode(dados),
      ),
    );
  }

  static Future<Map<String, dynamic>> atualizarProfessor(
    String id,
    Map<String, dynamic> dados,
  ) async {
    return _request(
      http.put(
        Uri.parse("$baseUrl/professor/$id"),
        headers: await _headers(),
        body: jsonEncode(dados),
      ),
    );
  }

  static Future<Map<String, dynamic>> deletarProfessor(String id) async {
    return _request(
      http.delete(
        Uri.parse("$baseUrl/professor/$id"),
        headers: await _headers(),
      ),
    );
  }

  // =========================
  // 📚 TURMAS
  // =========================
  static Future<List<Turma>> buscarTurmas() async {
    final res = await http.get(
      Uri.parse("$baseUrl/turma"),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Turma.fromJson(e)).toList();
    }

    return [];
  }

  static Future<Map<String, dynamic>> criarTurma(
    Map<String, dynamic> dados,
  ) async {
    return _request(
      http.post(
        Uri.parse("$baseUrl/turma"),
        headers: await _headers(),
        body: jsonEncode(dados),
      ),
    );
  }

  static Future<Map<String, dynamic>> atualizarTurma(
    String id,
    Map<String, dynamic> dados,
  ) async {
    return _request(
      http.put(
        Uri.parse("$baseUrl/turma/$id"),
        headers: await _headers(),
        body: jsonEncode(dados),
      ),
    );
  }

  static Future<Map<String, dynamic>> deletarTurma(String id) async {
    return _request(
      http.delete(Uri.parse("$baseUrl/turma/$id"), headers: await _headers()),
    );
  }

  // =========================
  // 🏫 ESCOLAS
  // =========================
  static Future<List<dynamic>> buscarEscolas() async {
    final res = await http.get(
      Uri.parse("$baseUrl/escola"),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    return [];
  }

  static Future<Map<String, dynamic>> criarEscola(
    Map<String, dynamic> dados,
  ) async {
    return _request(
      http.post(
        Uri.parse("$baseUrl/escola"),
        headers: await _headers(),
        body: jsonEncode(dados),
      ),
    );
  }

  static Future<Map<String, dynamic>> atualizarEscola(
    String id,
    Map<String, dynamic> dados,
  ) async {
    return _request(
      http.put(
        Uri.parse("$baseUrl/escola/$id"),
        headers: await _headers(),
        body: jsonEncode(dados),
      ),
    );
  }

  static Future<Map<String, dynamic>> deletarEscola(String id) async {
    return _request(
      http.delete(Uri.parse("$baseUrl/escola/$id"), headers: await _headers()),
    );
  }

  // =========================
  // 👨‍🎓 ALUNOS
  // =========================
  static Future<List<dynamic>> buscarAlunos() async {
    final res = await http.get(
      Uri.parse("$baseUrl/aluno"),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    return [];
  }

  static Future<Map<String, dynamic>> criarAluno(
    Map<String, dynamic> dados,
  ) async {
    return _request(
      http.post(
        Uri.parse("$baseUrl/aluno"),
        headers: await _headers(),
        body: jsonEncode(dados),
      ),
    );
  }

  static Future<Map<String, dynamic>> atualizarAluno(
    String id,
    Map<String, dynamic> dados,
  ) async {
    return _request(
      http.put(
        Uri.parse("$baseUrl/aluno/$id"),
        headers: await _headers(),
        body: jsonEncode(dados),
      ),
    );
  }

  static Future<Map<String, dynamic>> deletarAluno(String id) async {
    return _request(
      http.delete(Uri.parse("$baseUrl/aluno/$id"), headers: await _headers()),
    );
  }

  // =========================
  // 📘 DISCIPLINAS
  // =========================
  static Future<List<dynamic>> buscarDisciplinas() async {
    final res = await http.get(
      Uri.parse("$baseUrl/disciplina"),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    return [];
  }

  // =========================
  // 📊 DASHBOARD
  // =========================
  static Future<int> totalAlunos() async => (await buscarAlunos()).length;
  static Future<int> totalProfessores() async =>
      (await buscarProfessores()).length;
  static Future<int> totalTurmas() async => (await buscarTurmas()).length;
  static Future<int> totalEscolas() async => (await buscarEscolas()).length;

  // =========================
  // 🔧 POST COM AUTH (NOVO)
  // =========================
  static Future<http.Response> postComAuth(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    return await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: await _headers(),
      body: jsonEncode(body),
    );
  }

  // =========================
  // 🔗 PROFESSORES DA TURMA
  // =========================
  static Future<List<dynamic>> buscarProfessoresDaTurma(String turmaId) async {
    try {
      final token = await AuthService.pegarToken();

      final response = await http.get(
        Uri.parse("$baseUrl/turma/$turmaId/professores"),
        headers: {
          "Content-Type": "application/json",
          if (token != null && token.isNotEmpty && token != "super_admin")
            "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return [];
    } catch (e) {
      return [];
    }
  }
}
