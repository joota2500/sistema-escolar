import 'package:flutter/material.dart';

class SelectCidade extends StatelessWidget {
  final String? estado;
  final String? cidadeSelecionada;
  final Function(String?) onChanged;

  const SelectCidade({
    super.key,
    required this.estado,
    required this.cidadeSelecionada,
    required this.onChanged,
  });

  static const cidadesPorEstado = {
    "CE": [
      "Fortaleza",
      "Caucaia",
      "Juazeiro do Norte",
      "Sobral",
      "Crato",
      "Maracanaú",
      "Quixadá",
    ],
    "SP": ["São Paulo", "Campinas", "Santos", "Ribeirão Preto"],
    "RJ": ["Rio de Janeiro", "Niterói", "Duque de Caxias"],
    "MG": ["Belo Horizonte", "Uberlândia", "Contagem"],
    "BA": ["Salvador", "Feira de Santana", "Vitória da Conquista"],
  };

  @override
  Widget build(BuildContext context) {
    final cidades = estado != null
        ? cidadesPorEstado[estado] ?? []
        : <String>[];

    return DropdownButtonFormField<String>(
      initialValue: cidadeSelecionada,
      items: cidades
          .map((cidade) => DropdownMenuItem(value: cidade, child: Text(cidade)))
          .toList(),
      onChanged: estado == null ? null : onChanged,
      decoration: const InputDecoration(
        labelText: "Cidade",
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Selecione a cidade";
        }
        return null;
      },
    );
  }
}
