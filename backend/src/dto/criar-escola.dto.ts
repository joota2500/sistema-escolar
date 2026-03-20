export class CriarEscolaDTO {
  nome!: string;
  cnpj!: string;
  cidade!: string;
  estado!: string;
  tipo!: string;

  telefone?: string;
  email?: string;

  // 🔥 DIRETOR AGORA É ADMIN
  admin_nome!: string;
  admin_email!: string;
  admin_senha!: string;

  logo_url?: string;
  ano_letivo_atual?: number;
}
