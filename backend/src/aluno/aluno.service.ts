import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AlunoService {
  constructor(private readonly prisma: PrismaService) {}

  async criar(data: {
    nome: string;
    cpf: string;
    dataNascimento: string;
    matricula: string;
    turma_id: string;
    nomePai?: string;
    nomeMae?: string;
    responsavel?: string;
    telefoneResp?: string;
    emailResp?: string;
    endereco?: string;
  }) {
    return await this.prisma.aluno.create({
      data: {
        nome: data.nome,
        cpf: data.cpf,
        dataNascimento: new Date(data.dataNascimento),
        matricula: data.matricula,
        turma_id: data.turma_id,

        nomePai: data.nomePai ?? null,
        nomeMae: data.nomeMae ?? null,
        responsavel: data.responsavel ?? null,
        telefoneResp: data.telefoneResp ?? null,
        emailResp: data.emailResp ?? null,
        endereco: data.endereco ?? null,
      },
    });
  }

  // 🔥 LISTAR ALUNOS
  async listar() {
    return await this.prisma.aluno.findMany({
      include: {
        turma: true,
      },
      orderBy: {
        nome: 'asc',
      },
    });
  }

  // 🔥 BUSCAR POR ID
  async buscar(id: string) {
    const aluno = await this.prisma.aluno.findUnique({
      where: { id },
      include: { turma: true },
    });

    if (!aluno) {
      throw new NotFoundException('Aluno não encontrado');
    }

    return aluno;
  }

  // 🔥 DELETAR
  async deletar(id: string) {
    // verifica antes
    const aluno = await this.prisma.aluno.findUnique({
      where: { id },
    });

    if (!aluno) {
      throw new NotFoundException('Aluno não encontrado');
    }

    return await this.prisma.aluno.delete({
      where: { id },
    });
  }
}
