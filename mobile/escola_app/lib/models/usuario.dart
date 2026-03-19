class Usuario {
  final String id;
  final String nome;
  final String tipo;

  Usuario({required this.id, required this.nome, required this.tipo});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json["id"]?.toString() ?? "",
      nome: json["nome"] ?? "",
      tipo: json["tipo"] ?? "professor",
    );
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "nome": nome, "tipo": tipo};
  }
}
