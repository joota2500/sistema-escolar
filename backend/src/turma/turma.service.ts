import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class TurmaService {
  constructor(private prisma: PrismaService) {}

  // ==========================
  // CRIAR TURMA
  // ==========================
  async criarTurma(dados: any) {
    const escola = await this.prisma.escola.findUnique({
      where: { id: dados.escola_id },
    });

    if (!escola) {
      throw new NotFoundException('Escola não encontrada');
    }

    const turmaExistente = await this.prisma.turma.findFirst({
      where: {
        nome: dados.nome,
        escola_id: dados.escola_id,
        ano_letivo: dados.ano_letivo,
      },
    });

    if (turmaExistente) {
      throw new BadRequestException('Turma já existe');
    }

    return this.prisma.turma.create({
      data: dados,
    });
  }

  // ==========================
  // LISTAR
  // ==========================
  async listarTurmas() {
    return this.prisma.turma.findMany({
      include: {
        escola: true,
      },
    });
  }

  // ==========================
  // BUSCAR TURMA
  // ==========================
  async buscarTurma(id: string) {
    const turma = await this.prisma.turma.findUnique({
      where: { id },
      include: {
        professor_turma: {
          include: {
            professor: true, // 🔥 já traz professor junto
          },
        },
        horarios: true,
        observacoes_turma: true,
        alunos: true, // 🔥 já prepara próximo passo
      },
    });

    if (!turma) {
      throw new NotFoundException('Turma não encontrada');
    }

    return turma;
  }

  // ==========================
  // 🔗 PROFESSORES DA TURMA
  // ==========================
  async buscarProfessoresDaTurma(turmaId: string) {
    const data = await this.prisma.professorTurma.findMany({
      where: {
        turma_id: turmaId,
      },
      include: {
        professor: true,
      },
    });

    return data.map((item) => item.professor);
  }

  // ==========================
  // ATUALIZAR
  // ==========================
  async atualizarTurma(id: string, dados: any) {
    return this.prisma.turma.update({
      where: { id },
      data: dados,
    });
  }

  // ==========================
  // DELETAR
  // ==========================
  async deletarTurma(id: string) {
    await this.prisma.turma.delete({
      where: { id },
    });

    return { mensagem: 'Turma deletada' };
  }

  // ==========================
  // 🔗 VINCULAR PROFESSOR
  // ==========================
  async vincularProfessor(dados: any) {
    const professor = await this.prisma.professor.findUnique({
      where: { id: dados.professor_id },
    });

    if (!professor) {
      throw new NotFoundException('Professor não encontrado');
    }

    const turma = await this.prisma.turma.findUnique({
      where: { id: dados.turma_id },
    });

    if (!turma) {
      throw new NotFoundException('Turma não encontrada');
    }

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

  // ==========================
  // OBSERVAÇÃO
  // ==========================
  async criarObservacao(dados: any) {
    return this.prisma.observacaoTurma.create({
      data: dados,
    });
  }

  // ==========================
  // HORÁRIO
  // ==========================
  async criarHorario(dados: any) {
    return this.prisma.horario.create({
      data: {
        ...dados,
        hora_inicio: new Date(`1970-01-01T${dados.hora_inicio}:00`),
        hora_fim: new Date(`1970-01-01T${dados.hora_fim}:00`),
      },
    });
  }
}
