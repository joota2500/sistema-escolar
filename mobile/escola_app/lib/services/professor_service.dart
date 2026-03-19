import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_service.dart';
import 'auth_service.dart';

class ProfessorService {
  // ==========================
  // 🔍 BUSCAR
  // ==========================
  static Future<List<dynamic>> buscar() async {
    return await ApiService.buscarProfessores();
  }

  // ==========================
  // ➕ CRIAR
  // ==========================
  static Future<Map<String, dynamic>> criar(Map<String, dynamic> dados) async {
    return await ApiService.criarProfessor(dados);
  }

  // ==========================
  // ✏️ ATUALIZAR
  // ==========================
  static Future<Map<String, dynamic>> atualizar(
    String id,
    Map<String, dynamic> dados,
  ) async {
    return await ApiService.atualizarProfessor(id, dados);
  }

  // ==========================
  // ❌ DELETAR
  // ==========================
  static Future<Map<String, dynamic>> deletar(String id) async {
    return await ApiService.deletarProfessor(id);
  }

  // ==========================
  // 🔗 VINCULAR PROFESSOR À TURMA
  // ==========================
  static Future<Map<String, dynamic>> vincularTurma({
    required String professorId,
    required String turmaId,
  }) async {
    try {
      final token = await AuthService.pegarToken();

      final headers = {
        "Content-Type": "application/json",
        if (token != null && token.isNotEmpty && token != "super_admin")
          "Authorization": "Bearer $token",
      };

      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/turma/vincular-professor"),
        headers: headers,
        body: jsonEncode({"professor_id": professorId, "turma_id": turmaId}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data is Map<String, dynamic>
            ? data
            : {"sucesso": true, "data": data};
      }

      return {
        "erro": data["message"] ?? data["erro"] ?? "Erro ao vincular professor",
      };
    } catch (e) {
      return {"erro": "Erro de conexão com servidor"};
    }
  }
}
