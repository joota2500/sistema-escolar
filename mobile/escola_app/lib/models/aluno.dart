class Aluno {
  final String id;
  final String nome;
  final String matricula;
  final String turmaId;

  Aluno({
    required this.id,
    required this.nome,
    required this.matricula,
    required this.turmaId,
  });

  factory Aluno.fromJson(Map<String, dynamic> json) {
    return Aluno(
      id: json["id"] ?? "",
      nome: json["nome"] ?? "",
      matricula: json["matricula"] ?? "",
      turmaId: json["turma_id"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nome": nome,
      "matricula": matricula,
      "turma_id": turmaId,
    };
  }
}
