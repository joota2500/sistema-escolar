import 'api_service.dart';

class EscolaService {
  static Future<dynamic> buscar() async {
    return await ApiService.buscarEscolas();
  }

  static Future<dynamic> criar(Map<String, dynamic> dados) async {
    return await ApiService.criarEscola(dados);
  }

  static Future<dynamic> atualizar(
    String id,
    Map<String, dynamic> dados,
  ) async {
    return await ApiService.atualizarEscola(id, dados);
  }

  static Future<dynamic> deletar(String id) async {
    return await ApiService.deletarEscola(id);
  }
}
