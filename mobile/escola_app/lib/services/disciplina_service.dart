import 'api_service.dart';

class DisciplinaService {
  static Future<List<Map<String, dynamic>>> listarDisciplinas() async {
    final result = await ApiService.buscarDisciplinas();

    if (result.isEmpty) {
      return [];
    }

    return List<Map<String, dynamic>>.from(result);
  }
}
