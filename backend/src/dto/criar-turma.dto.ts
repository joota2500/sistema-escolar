export class CriarTurmaDTO {
  nome!: string;
  serie!: number;
  identificador!: string; // ex: "A", "B"
  turno!: 'manha' | 'tarde' | 'noite';
  sala!: string;
  capacidade!: number;
  ano_letivo!: number;
  escola_id!: string;
}
