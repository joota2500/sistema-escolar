export class CreateAlunoDTO {
  nome!: string;
  cpf!: string;
  dataNascimento!: string;
  turma_id!: string;

  nomePai?: string;
  nomeMae?: string;
  responsavel?: string;
  telefoneResp?: string;
  emailResp?: string;
  endereco?: string;
}
