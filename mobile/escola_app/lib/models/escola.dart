class Escola {
  final String id;
  final String nome;
  final String cidade;
  final String estado;

  Escola({
    required this.id,
    required this.nome,
    required this.cidade,
    required this.estado,
  });

  factory Escola.fromJson(Map<String, dynamic> json) {
    return Escola(
      id: json["id"] ?? "",
      nome: json["nome"] ?? "",
      cidade: json["cidade"] ?? "",
      estado: json["estado"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "nome": nome, "cidade": cidade, "estado": estado};
  }
}
