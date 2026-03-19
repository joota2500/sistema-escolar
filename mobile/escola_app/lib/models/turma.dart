class Turma {
  final String id;
  final String nome;
  final int serie;
  final String identificador;
  final String turno;
  final String sala;
  final int capacidade;
  final int anoLetivo;
  final String escolaId;

  Turma({
    required this.id,
    required this.nome,
    required this.serie,
    required this.identificador,
    required this.turno,
    required this.sala,
    required this.capacidade,
    required this.anoLetivo,
    required this.escolaId,
  });

  factory Turma.fromJson(Map<String, dynamic> json) {
    return Turma(
      id: json["id"]?.toString() ?? "",
      nome: json["nome"] ?? "",
      serie: json["serie"] is int
          ? json["serie"]
          : int.tryParse(json["serie"]?.toString() ?? "0") ?? 0,
      identificador: json["identificador"] ?? "",
      turno: json["turno"] ?? "",
      sala: json["sala"] ?? "",
      capacidade: json["capacidade"] is int
          ? json["capacidade"]
          : int.tryParse(json["capacidade"]?.toString() ?? "0") ?? 0,
      anoLetivo: json["ano_letivo"] is int
          ? json["ano_letivo"]
          : int.tryParse(json["ano_letivo"]?.toString() ?? "0") ?? 0,
      escolaId: json["escola_id"]?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nome": nome,
      "serie": serie,
      "identificador": identificador,
      "turno": turno,
      "sala": sala,
      "capacidade": capacidade,
      "ano_letivo": anoLetivo,
      "escola_id": escolaId,
    };
  }
}
