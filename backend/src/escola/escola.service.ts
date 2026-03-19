import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { CriarEscolaDTO } from '../dto/criar-escola.dto';

@Injectable()
export class EscolaService {
  constructor(private prisma: PrismaService) {}

  private gerarCodigoEscola(): string {
    const numero = Math.floor(1000 + Math.random() * 9000);
    return `ESC-${numero}`;
  }

  private validarCNPJ(cnpj: string): boolean {
    return /^[0-9]{14}$/.test(cnpj);
  }

  private validarEmail(email: string): boolean {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  }

  // =============================
  // CRIAR
  // =============================
  async criarEscola(dados: CriarEscolaDTO) {
    const { nome, cnpj, cidade, estado, tipo } = dados;

    if (!nome || !cnpj || !cidade || !estado || !tipo) {
      throw new BadRequestException('Dados obrigatórios faltando');
    }

    if (!this.validarCNPJ(cnpj)) {
      throw new BadRequestException('CNPJ inválido');
    }

    if (dados.email && !this.validarEmail(dados.email)) {
      throw new BadRequestException('Email inválido');
    }

    const existente = await this.prisma.escola.findUnique({
      where: { cnpj },
    });

    if (existente) {
      throw new BadRequestException('CNPJ já cadastrado');
    }

    // 🔥 gerar código único
    let codigo = this.gerarCodigoEscola();

    while (
      await this.prisma.escola.findFirst({
        where: { codigo_escola: codigo },
      })
    ) {
      codigo = this.gerarCodigoEscola();
    }

    const escola = await this.prisma.escola.create({
      data: {
        nome,
        cnpj,
        cidade,
        estado,
        tipo,
        ativa: true,
        codigo_escola: codigo,
      },
    });

    // 🔥 NOVO: ALERTA SE NÃO TIVER ADMIN
    const totalAdmins = await this.prisma.adminEscola.count({
      where: { escola_id: escola.id },
    });

    return {
      sucesso: true,
      escola,
      alerta:
        totalAdmins === 0
          ? '⚠️ Escola criada, mas precisa de um administrador para funcionar'
          : null,
    };
  }

  // =============================
  // LISTAR
  // =============================
  listarEscolas() {
    return this.prisma.escola.findMany({
      orderBy: { nome: 'asc' },
    });
  }

  // =============================
  // BUSCAR
  // =============================
  async buscarEscola(id: string) {
    const escola = await this.prisma.escola.findUnique({
      where: { id },
      include: {
        professores: true,
        turmas: true,
      },
    });

    if (!escola) {
      throw new NotFoundException('Escola não encontrada');
    }

    return escola;
  }

  // =============================
  // STATUS (🔥 NOVO)
  // =============================
  async statusEscola(id: string) {
    const escola = await this.prisma.escola.findUnique({
      where: { id },
    });

    if (!escola) {
      throw new NotFoundException('Escola não encontrada');
    }

    const totalAdmins = await this.prisma.adminEscola.count({
      where: { escola_id: id },
    });

    return {
      escola,
      status:
        totalAdmins === 0 ? '⚠️ Escola sem administrador' : '✅ Escola ativa',
    };
  }

  // =============================
  // ATUALIZAR
  // =============================
  async atualizarEscola(id: string, dados: Partial<CriarEscolaDTO>) {
    const escola = await this.prisma.escola.findUnique({
      where: { id },
    });

    if (!escola) {
      throw new NotFoundException('Escola não encontrada');
    }

    if (dados.cnpj && !this.validarCNPJ(dados.cnpj)) {
      throw new BadRequestException('CNPJ inválido');
    }

    if (dados.cnpj && dados.cnpj !== escola.cnpj) {
      const existe = await this.prisma.escola.findUnique({
        where: { cnpj: dados.cnpj },
      });

      if (existe) {
        throw new BadRequestException('CNPJ já cadastrado');
      }
    }

    return this.prisma.escola.update({
      where: { id },
      data: {
        nome: dados.nome ?? escola.nome,
        cnpj: dados.cnpj ?? escola.cnpj,
        cidade: dados.cidade ?? escola.cidade,
        estado: dados.estado ?? escola.estado,
        tipo: dados.tipo ?? escola.tipo,
        atualizado_em: new Date(),
      },
    });
  }

  // =============================
  // DELETAR
  // =============================
  async deletarEscola(id: string) {
    await this.buscarEscola(id);

    const professores = await this.prisma.professor.count({
      where: { escola_id: id },
    });

    if (professores > 0) {
      throw new BadRequestException('Existe professor vinculado');
    }

    const turmas = await this.prisma.turma.count({
      where: { escola_id: id },
    });

    if (turmas > 0) {
      throw new BadRequestException('Existe turma vinculada');
    }

    await this.prisma.escola.delete({
      where: { id },
    });

    return { sucesso: true };
  }

  // =============================
  // PROFESSORES
  // =============================
  listarProfessoresDaEscola(id: string) {
    return this.prisma.professor.findMany({
      where: { escola_id: id },
      orderBy: { nome: 'asc' },
    });
  }
}
