import {
  Injectable,
  BadRequestException,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { CriarEscolaDTO } from '../dto/criar-escola.dto';
import * as bcrypt from 'bcrypt';
import { UsuarioLogado } from '../common/interfaces/usuario-logado.interface';

@Injectable()
export class EscolaService {
  constructor(private prisma: PrismaService) {}

  // =============================
  // 🔐 VALIDA ACESSO
  // =============================
  private validarAcesso(user: UsuarioLogado, escola_id: string) {
    if (user.role === 'superadmin') return;

    if (!user.escola_id || user.escola_id !== escola_id) {
      throw new ForbiddenException('Acesso negado');
    }
  }

  // =============================
  // 🔍 GARANTE EXISTÊNCIA
  // =============================
  private async validarExistencia(id: string) {
    const escola = await this.prisma.escola.findUnique({
      where: { id },
    });

    if (!escola) {
      throw new NotFoundException('Escola não encontrada');
    }

    return escola;
  }

  // =============================
  // 🔢 GERAR CÓDIGO
  // =============================
  private gerarCodigoEscola(): string {
    return `ESC-${Math.floor(1000 + Math.random() * 9000)}`;
  }

  // =============================
  // 🔥 CRIAR ESCOLA + DIRETOR
  // =============================
  async criarEscola(dados: CriarEscolaDTO, user: UsuarioLogado) {
    console.log('USER CREATE ESCOLA:', user); // 🔥 debug

    if (!user || user.role !== 'superadmin') {
      throw new ForbiddenException('Somente superadmin pode criar escola');
    }

    if (!dados.nome || !dados.cnpj || !dados.admin_nome || !dados.admin_email) {
      throw new BadRequestException('Dados obrigatórios faltando');
    }

    const existente = await this.prisma.escola.findUnique({
      where: { cnpj: dados.cnpj },
    });

    if (existente) {
      throw new BadRequestException('CNPJ já cadastrado');
    }

    // 🔥 senha automática
    const senhaPadrao = `ESC${Math.floor(1000 + Math.random() * 9000)}`;
    const senhaHash = await bcrypt.hash(senhaPadrao, 10);

    return this.prisma.$transaction(async (tx) => {
      const escola = await tx.escola.create({
        data: {
          nome: dados.nome,
          cnpj: dados.cnpj,
          cidade: dados.cidade,
          estado: dados.estado,
          tipo: dados.tipo,
          ativa: true,
          codigo_escola: this.gerarCodigoEscola(),
        },
      });

      const admin = await tx.admin.create({
        data: {
          nome: dados.admin_nome,
          email: dados.admin_email,
          senha: senhaHash,
          role: 'admin',
          primeiro_acesso: true,
        },
      });

      await tx.adminEscola.create({
        data: {
          admin_id: admin.id,
          escola_id: escola.id,
        },
      });

      return {
        sucesso: true,
        escola,
        admin: {
          email: admin.email,
          senha_inicial: senhaPadrao,
        },
      };
    });
  }

  // =============================
  // 📋 LISTAR
  // =============================
  async listarEscolas(user: UsuarioLogado) {
    if (user.role === 'superadmin') {
      return this.prisma.escola.findMany({
        orderBy: { nome: 'asc' },
      });
    }

    return this.prisma.escola.findMany({
      where: {
        adminEscolas: {
          some: {
            admin_id: user.id, // ✅ CORRETO
          },
        },
      },
    });
  }

  // =============================
  // 🔍 BUSCAR
  // =============================
  async buscarEscola(id: string, user: UsuarioLogado) {
    const escola = await this.validarExistencia(id);
    this.validarAcesso(user, id);
    return escola;
  }

  // =============================
  // 📊 STATUS
  // =============================
  async statusEscola(id: string, user: UsuarioLogado) {
    this.validarAcesso(user, id);

    const escola = await this.validarExistencia(id);

    const totalAdmins = await this.prisma.adminEscola.count({
      where: { escola_id: id },
    });

    return {
      ativa: escola.ativa,
      manutencao: escola.modo_manutencao,
      motivo: escola.motivo_bloqueio,
      bloqueada_em: escola.bloqueada_em,
      totalAdmins,
      status: !escola.ativa
        ? '🔒 Bloqueada'
        : escola.modo_manutencao
          ? '🛠 Em manutenção'
          : totalAdmins === 0
            ? '⚠️ Sem administrador'
            : '✅ Ativa',
    };
  }

  // =============================
  // ✏️ ATUALIZAR
  // =============================
  async atualizarEscola(
    id: string,
    dados: Partial<CriarEscolaDTO>,
    user: UsuarioLogado,
  ) {
    this.validarAcesso(user, id);
    await this.validarExistencia(id);

    return this.prisma.escola.update({
      where: { id },
      data: {
        ...(dados.nome && { nome: dados.nome }),
        ...(dados.cidade && { cidade: dados.cidade }),
        ...(dados.estado && { estado: dados.estado }),
        ...(dados.tipo && { tipo: dados.tipo }),
      },
    });
  }

  // =============================
  // ❌ DELETAR
  // =============================
  async deletarEscola(id: string, user: UsuarioLogado) {
    if (user.role !== 'superadmin') {
      throw new ForbiddenException('Somente superadmin');
    }

    await this.validarExistencia(id);

    await this.prisma.escola.delete({
      where: { id },
    });

    return { sucesso: true };
  }

  // =============================
  // 👨‍🏫 PROFESSORES
  // =============================
  async listarProfessoresDaEscola(id: string, user: UsuarioLogado) {
    this.validarAcesso(user, id);

    return this.prisma.professor.findMany({
      where: { escola_id: id },
    });
  }

  // =============================
  // 🔓 ATIVAR
  // =============================
  async ativarEscola(id: string, user: UsuarioLogado) {
    if (user.role !== 'superadmin') throw new ForbiddenException();

    await this.validarExistencia(id);

    return this.prisma.escola.update({
      where: { id },
      data: {
        ativa: true,
        motivo_bloqueio: null,
        bloqueada_em: null,
      },
    });
  }

  // =============================
  // 🔒 DESATIVAR
  // =============================
  async desativarEscola(id: string, motivo: string, user: UsuarioLogado) {
    if (user.role !== 'superadmin') throw new ForbiddenException();

    if (!motivo) {
      throw new BadRequestException('Motivo obrigatório');
    }

    await this.validarExistencia(id);

    return this.prisma.escola.update({
      where: { id },
      data: {
        ativa: false,
        motivo_bloqueio: motivo,
        bloqueada_em: new Date(),
      },
    });
  }

  // =============================
  // 🔧 MANUTENÇÃO
  // =============================
  async manutencaoEscola(id: string, status: boolean, user: UsuarioLogado) {
    if (user.role !== 'superadmin') throw new ForbiddenException();

    await this.validarExistencia(id);

    return this.prisma.escola.update({
      where: { id },
      data: {
        modo_manutencao: status,
      },
    });
  }
}
