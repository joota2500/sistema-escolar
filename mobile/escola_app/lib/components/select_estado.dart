import 'package:flutter/material.dart';

class SelectEstado extends StatelessWidget {
  final String? estadoSelecionado;
  final Function(String?) onChanged;

  const SelectEstado({
    super.key,
    this.estadoSelecionado,
    required this.onChanged,
  });

  static const estados = [
    "AC",
    "AL",
    "AP",
    "AM",
    "BA",
    "CE",
    "DF",
    "ES",
    "GO",
    "MA",
    "MT",
    "MS",
    "MG",
    "PA",
    "PB",
    "PR",
    "PE",
    "PI",
    "RJ",
    "RN",
    "RS",
    "RO",
    "RR",
    "SC",
    "SP",
    "SE",
    "TO",
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: estadoSelecionado,
      items: estados
          .map((estado) => DropdownMenuItem(value: estado, child: Text(estado)))
          .toList(),
      onChanged: onChanged,
      decoration: const InputDecoration(
        labelText: "Estado",
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Selecione um estado";
        }
        return null;
      },
    );
  }
}
