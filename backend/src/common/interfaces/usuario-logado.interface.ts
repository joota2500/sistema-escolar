export interface UsuarioLogado {
  id: string;
  nome: string;
  role: string;
  escola_id?: string | null;
}
