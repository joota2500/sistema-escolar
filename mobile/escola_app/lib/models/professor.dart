class Professor {
  final String id;
  final String nome;
  final String cpf;
  final String email;
  final String disciplina;
  final String escolaId;
  final String status;

  Professor({
    required this.id,
    required this.nome,
    required this.cpf,
    required this.email,
    required this.disciplina,
    required this.escolaId,
    required this.status,
  });

  // ==========================
  // 🔄 FROM JSON
  // ==========================
  factory Professor.fromJson(Map<String, dynamic> json) {
    return Professor(
      id: json["id"] ?? "",
      nome: json["nome"] ?? "",
      cpf: json["cpf"] ?? "",
      email: json["email"] ?? "",
      disciplina: json["disciplina"] ?? "",
      escolaId: json["escola_id"] ?? "",
      status: json["status"] ?? "ativo",
    );
  }

  // ==========================
  // 🔁 TO JSON
  // ==========================
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nome": nome,
      "cpf": cpf,
      "email": email,
      "disciplina": disciplina,
      "escola_id": escolaId,
      "status": status,
    };
  }

  // ==========================
  // 🧠 HELPERS (NOVO)
  // ==========================
  String get nomeFormatado => nome;

  bool get ativo => status == "ativo";
}
