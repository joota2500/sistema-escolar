class Disciplina {
  final String nome;

  Disciplina({required this.nome});

  factory Disciplina.fromJson(Map<String, dynamic> json) {
    return Disciplina(nome: json["nome"]);
  }
}
