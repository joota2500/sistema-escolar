import {
  Injectable,
  BadRequestException,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { CriarTurmaDTO } from '../dto/criar-turma.dto';
import { UsuarioLogado } from '../common/interfaces/usuario-logado.interface';

@Injectable()
export class TurmaService {
  constructor(private prisma: PrismaService) {}

  private validarAcesso(user: UsuarioLogado, escola_id: string) {
    if (user.role === 'superadmin') return;

    if (user.escola_id !== escola_id) {
      throw new ForbiddenException('Acesso negado');
    }
  }

  async criarTurma(dados: CriarTurmaDTO, user: UsuarioLogado) {
    if (!dados.nome || !dados.turno || !dados.ano_letivo) {
      throw new BadRequestException('Dados obrigatórios faltando');
    }

    if (user.role !== 'superadmin') {
      dados.escola_id = user.escola_id!;
    }

    const escola = await this.prisma.escola.findUnique({
      where: { id: dados.escola_id },
    });

    if (!escola) {
      throw new NotFoundException('Escola não encontrada');
    }

    const existe = await this.prisma.turma.findFirst({
      where: {
        nome: dados.nome,
        identificador: dados.identificador,
        escola_id: dados.escola_id,
        ano_letivo: dados.ano_letivo,
      },
    });

    if (existe) {
      throw new BadRequestException('Turma já existe');
    }

    return this.prisma.turma.create({
      data: {
        nome: dados.nome,
        serie: Number(dados.serie),
        identificador: dados.identificador,
        turno: dados.turno,
        sala: dados.sala,
        capacidade: Number(dados.capacidade),
        ano_letivo: Number(dados.ano_letivo),
        escola_id: dados.escola_id,
      },
    });
  }

  async listarTurmas(user: UsuarioLogado) {
    if (user.role === 'superadmin') {
      return this.prisma.turma.findMany({
        include: { escola: true },
        orderBy: { nome: 'asc' },
      });
    }

    return this.prisma.turma.findMany({
      where: {
        ...(user.escola_id && { escola_id: user.escola_id }),
      },
      include: { escola: true },
      orderBy: { nome: 'asc' },
    });
  }

  async buscarTurma(id: string, user: UsuarioLogado) {
    const turma = await this.prisma.turma.findUnique({
      where: { id },
      include: {
        professor_turma: {
          include: { professor: true },
        },
        alunos: true,
      },
    });

    if (!turma) {
      throw new NotFoundException('Turma não encontrada');
    }

    this.validarAcesso(user, turma.escola_id);

    return turma;
  }

  async buscarProfessoresDaTurma(turmaId: string, user: UsuarioLogado) {
    const turma = await this.prisma.turma.findUnique({
      where: { id: turmaId },
    });

    if (!turma) {
      throw new NotFoundException('Turma não encontrada');
    }

    this.validarAcesso(user, turma.escola_id);

    const data = await this.prisma.professorTurma.findMany({
      where: { turma_id: turmaId },
      include: { professor: true },
    });

    return data.map((item) => item.professor);
  }

  async atualizarTurma(
    id: string,
    dados: Partial<CriarTurmaDTO>,
    user: UsuarioLogado,
  ) {
    const turma = await this.prisma.turma.findUnique({
      where: { id },
    });

    if (!turma) {
      throw new NotFoundException('Turma não encontrada');
    }

    this.validarAcesso(user, turma.escola_id);

    return this.prisma.turma.update({
      where: { id },
      data: {
        nome: dados.nome,
        serie: dados.serie ? Number(dados.serie) : undefined,
        identificador: dados.identificador,
        turno: dados.turno,
        sala: dados.sala,
        capacidade: dados.capacidade ? Number(dados.capacidade) : undefined,
        ano_letivo: dados.ano_letivo ? Number(dados.ano_letivo) : undefined,
      },
    });
  }

  async deletarTurma(id: string, user: UsuarioLogado) {
    const turma = await this.prisma.turma.findUnique({
      where: { id },
    });

    if (!turma) {
      throw new NotFoundException('Turma não encontrada');
    }

    this.validarAcesso(user, turma.escola_id);

    await this.prisma.turma.delete({ where: { id } });

    return { mensagem: 'Turma deletada' };
  }

  async vincularProfessor(
    dados: {
      turma_id: string;
      professor_id: string;
      disciplina?: string;
    },
    user: UsuarioLogado,
  ) {
    const turma = await this.prisma.turma.findUnique({
      where: { id: dados.turma_id },
    });

    if (!turma) {
      throw new NotFoundException('Turma não encontrada');
    }

    this.validarAcesso(user, turma.escola_id);

    const existe = await this.prisma.professorTurma.findFirst({
      where: {
        professor_id: dados.professor_id,
        turma_id: dados.turma_id,
      },
    });

    if (existe) {
      throw new BadRequestException('Já vinculado');
    }

    return this.prisma.professorTurma.create({
      data: {
        professor_id: dados.professor_id,
        turma_id: dados.turma_id,
        disciplina: dados.disciplina || 'Geral',
      },
    });
  }

  async criarObservacao(dados: {
    turma_id: string;
    professor_id: string;
    observacao: string;
  }) {
    return this.prisma.observacaoTurma.create({ data: dados });
  }

  async criarHorario(dados: {
    turma_id: string;
    professor_id: string;
    disciplina: string;
    dia_semana: string;
    hora_inicio: string;
    hora_fim: string;
  }) {
    return this.prisma.horario.create({
      data: {
        ...dados,
        hora_inicio: new Date(`1970-01-01T${dados.hora_inicio}:00`),
        hora_fim: new Date(`1970-01-01T${dados.hora_fim}:00`),
      },
    });
  }
}
