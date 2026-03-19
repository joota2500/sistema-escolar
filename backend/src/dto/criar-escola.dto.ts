export class CriarEscolaDTO {
  nome!: string;
  cnpj!: string;
  cidade!: string;
  estado!: string;
  tipo!: string;

  telefone?: string;
  email?: string;

  diretor_nome?: string;
  diretor_email?: string;
  diretor_telefone?: string;

  logo_url?: string;

  ano_letivo_atual?: number;
}
