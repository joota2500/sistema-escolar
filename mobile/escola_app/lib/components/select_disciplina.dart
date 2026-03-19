import 'package:flutter/material.dart';

class SelectDisciplina extends StatelessWidget {
  final String? value;
  final List<Map<String, dynamic>> disciplinas;
  final Function(String?) onChanged;

  const SelectDisciplina({
    super.key,
    this.value,
    required this.disciplinas,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,

      items: disciplinas.map((disciplina) {
        return DropdownMenuItem<String>(
          value: disciplina["nome"],
          child: Text(disciplina["nome"]),
        );
      }).toList(),

      onChanged: onChanged,

      decoration: const InputDecoration(
        labelText: "Disciplina",
        border: OutlineInputBorder(),
      ),
    );
  }
}
