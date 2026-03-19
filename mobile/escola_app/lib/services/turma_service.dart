import 'api_service.dart';

class TurmaService {
  static Future<dynamic> buscar() async {
    return await ApiService.buscarTurmas();
  }

  static Future<dynamic> criar(Map<String, dynamic> dados) async {
    return await ApiService.criarTurma(dados);
  }

  static Future<dynamic> atualizar(
    String id,
    Map<String, dynamic> dados,
  ) async {
    return await ApiService.atualizarTurma(id, dados);
  }

  static Future<dynamic> deletar(String id) async {
    return await ApiService.deletarTurma(id);
  }
}
