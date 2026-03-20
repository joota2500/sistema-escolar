import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { CreateAlunoDTO } from '../dto/criar-aluno.dto';
import { UsuarioLogado } from '../common/interfaces/usuario-logado.interface';

@Injectable()
export class AlunoService {
  constructor(private readonly prisma: PrismaService) {}

  // ==========================
  // 🔐 VALIDAÇÃO DE ACESSO
  // ==========================
  private validarAcesso(user: UsuarioLogado, escola_id: string) {
    if (user.role === 'superadmin') return;

    if (user.escola_id !== escola_id) {
      throw new ForbiddenException('Acesso negado');
    }
  }

  // ==========================
  // 🔥 CRIAR ALUNO
  // ==========================
  async criar(data: CreateAlunoDTO, user: UsuarioLogado) {
    if (!data.nome || !data.cpf || !data.dataNascimento || !data.turma_id) {
      throw new BadRequestException('Dados obrigatórios faltando');
    }

    const turma = await this.prisma.turma.findUnique({
      where: { id: data.turma_id },
    });

    if (!turma) {
      throw new NotFoundException('Turma não encontrada');
    }

    this.validarAcesso(user, turma.escola_id);

    const dataNascimento = new Date(data.dataNascimento);

    if (isNaN(dataNascimento.getTime())) {
      throw new BadRequestException('Data de nascimento inválida');
    }

    const matricula = `MAT-${data.cpf}`;

    const cpfExistente = await this.prisma.aluno.findUnique({
      where: { cpf: data.cpf },
    });

    if (cpfExistente) {
      throw new BadRequestException('CPF já cadastrado');
    }

    return this.prisma.aluno.create({
      data: {
        nome: data.nome,
        cpf: data.cpf,
        dataNascimento,
        matricula,
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

  // ==========================
  // LISTAR
  // ==========================
  async listar(user: UsuarioLogado) {
    if (user.role === 'superadmin') {
      return this.prisma.aluno.findMany({
        include: { turma: true },
        orderBy: { nome: 'asc' },
      });
    }

    return this.prisma.aluno.findMany({
      where: {
        turma: {
          ...(user.escola_id && { escola_id: user.escola_id }),
        },
      },
      include: { turma: true },
      orderBy: { nome: 'asc' },
    });
  }
  // ==========================
  // BUSCAR
  // ==========================
  async buscar(id: string, user: UsuarioLogado) {
    const aluno = await this.prisma.aluno.findUnique({
      where: { id },
      include: { turma: true },
    });

    if (!aluno) {
      throw new NotFoundException('Aluno não encontrado');
    }

    this.validarAcesso(user, aluno.turma.escola_id);

    return aluno;
  }

  // ==========================
  // DELETAR
  // ==========================
  async deletar(id: string, user: UsuarioLogado) {
    const aluno = await this.prisma.aluno.findUnique({
      where: { id },
      include: { turma: true },
    });

    if (!aluno) {
      throw new NotFoundException('Aluno não encontrado');
    }

    this.validarAcesso(user, aluno.turma.escola_id);

    return this.prisma.aluno.delete({
      where: { id },
    });
  }
}
