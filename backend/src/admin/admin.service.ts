import {
  Injectable,
  BadRequestException,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import * as bcrypt from 'bcrypt';
import { AuthService } from '../auth/auth.service';
import { UsuarioLogado } from '../common/interfaces/usuario-logado.interface';

interface CriarAdminDTO {
  nome: string;
  email: string;
  senha: string;
}

interface LoginDTO {
  email: string;
  senha: string;
}

@Injectable()
export class AdminService {
  constructor(
    private prisma: PrismaService,
    private authService: AuthService,
  ) {}

  // =============================
  // 🔐 REMOVE SENHA
  // =============================
  private removerSenha(admin: any) {
    const { senha: _senha, ...resto } = admin;
    return resto;
  }

  // =============================
  // 🔐 CRIAR ADMIN
  // =============================
  async criarAdmin(dados: CriarAdminDTO, user: UsuarioLogado) {
    if (user.role !== 'superadmin') {
      throw new ForbiddenException('Apenas superadmin pode criar admins');
    }

    const { nome, email, senha } = dados;

    if (!nome || !email || !senha) {
      throw new BadRequestException('Dados obrigatórios faltando');
    }

    const existe = await this.prisma.admin.findUnique({
      where: { email },
    });

    if (existe) {
      throw new BadRequestException('Email já cadastrado');
    }

    const senhaHash = await bcrypt.hash(senha, 10);

    const admin = await this.prisma.admin.create({
      data: {
        nome,
        email,
        senha: senhaHash,
        role: 'admin',
      },
    });

    return this.removerSenha(admin);
  }

  // =============================
  // 🔐 LOGIN (CORRIGIDO)
  // =============================
  async login(dados: LoginDTO) {
    const { email, senha } = dados;

    if (!email || !senha) {
      throw new BadRequestException('Email e senha obrigatórios');
    }

    const admin = await this.prisma.admin.findUnique({
      where: { email },
    });

    if (!admin) {
      throw new BadRequestException('Credenciais inválidas');
    }

    const senhaValida = await bcrypt.compare(senha, admin.senha);

    if (!senhaValida) {
      throw new BadRequestException('Credenciais inválidas');
    }

    // 🔥 VERIFICA VÍNCULO COM ESCOLA
    const vinculo = await this.prisma.adminEscola.findFirst({
      where: { admin_id: admin.id },
    });

    // ❗ REGRA: admin comum PRECISA de escola
    if (!vinculo && admin.role !== 'superadmin') {
      throw new BadRequestException(
        'Admin não vinculado a nenhuma escola',
      );
    }

    // ✅ CORREÇÃO AQUI (sem null)
    const escola_id = vinculo?.escola_id;

    const token = this.authService.gerarToken({
      id: admin.id,
      nome: admin.nome,
      role: admin.role,
      escola_id,
    });

    return {
      access_token: token.access_token,
      usuario: {
        ...this.removerSenha(admin),
        escola_id,
      },
    };
  }

  // =============================
  // 📋 LISTAR ADMINS
  // =============================
  async listarAdmins(user: UsuarioLogado) {
    if (user.role !== 'superadmin') {
      throw new ForbiddenException('Apenas superadmin pode listar admins');
    }

    const admins = await this.prisma.admin.findMany({
      orderBy: { nome: 'asc' },
    });

    return admins.map((admin) => this.removerSenha(admin));
  }

  // =============================
  // 🔗 VINCULAR ADMIN
  // =============================
  async vincularEscola(
    admin_id: string,
    escola_id: string,
    user: UsuarioLogado,
  ) {
    if (user.role !== 'superadmin') {
      throw new ForbiddenException('Apenas superadmin pode vincular');
    }

    const admin = await this.prisma.admin.findUnique({
      where: { id: admin_id },
    });

    if (!admin) {
      throw new NotFoundException('Admin não encontrado');
    }

    const escola = await this.prisma.escola.findUnique({
      where: { id: escola_id },
    });

    if (!escola) {
      throw new NotFoundException('Escola não encontrada');
    }

    const existe = await this.prisma.adminEscola.findFirst({
      where: { admin_id, escola_id },
    });

    if (existe) {
      throw new BadRequestException('Admin já vinculado à escola');
    }

    const total = await this.prisma.adminEscola.count({
      where: { escola_id },
    });

    if (total >= 2) {
      throw new BadRequestException('Máximo 2 admins por escola');
    }

    return this.prisma.adminEscola.create({
      data: {
        admin_id,
        escola_id,
      },
    });
  }

  // =============================
  // ❌ DESVINCULAR ADMIN
  // =============================
  async desvincularAdmin(
    admin_id: string,
    escola_id: string,
    user: UsuarioLogado,
  ) {
    if (user.role !== 'superadmin') {
      throw new ForbiddenException('Apenas superadmin pode desvincular');
    }

    const vinculo = await this.prisma.adminEscola.findFirst({
      where: { admin_id, escola_id },
    });

    if (!vinculo) {
      throw new NotFoundException('Vínculo não encontrado');
    }

    const total = await this.prisma.adminEscola.count({
      where: { escola_id },
    });

    if (total <= 1) {
      throw new BadRequestException(
        'A escola deve possuir pelo menos 1 admin',
      );
    }

    await this.prisma.adminEscola.delete({
      where: { id: vinculo.id },
    });

    return { mensagem: 'Admin desvinculado com sucesso' };
  }

  // =============================
  // ✏️ ATUALIZAR ADMIN
  // =============================
  async atualizarAdmin(
    id: string,
    dados: { nome?: string; email?: string },
    user: UsuarioLogado,
  ) {
    if (user.role !== 'superadmin') {
      throw new ForbiddenException('Apenas superadmin pode editar');
    }

    const admin = await this.prisma.admin.findUnique({
      where: { id },
    });

    if (!admin) {
      throw new NotFoundException('Admin não encontrado');
    }

    if (dados.email && dados.email !== admin.email) {
      const existe = await this.prisma.admin.findUnique({
        where: { email: dados.email },
      });

      if (existe) {
        throw new BadRequestException('Email já está em uso');
      }
    }

    const atualizado = await this.prisma.admin.update({
      where: { id },
      data: {
        ...(dados.nome && { nome: dados.nome }),
        ...(dados.email && { email: dados.email }),
      },
    });

    return this.removerSenha(atualizado);
  }

  // =============================
  // ❌ DELETAR ADMIN
  // =============================
  async deletarAdmin(id: string, user: UsuarioLogado) {
    if (user.role !== 'superadmin') {
      throw new ForbiddenException('Apenas superadmin pode deletar');
    }

    const admin = await this.prisma.admin.findUnique({
      where: { id },
    });

    if (!admin) {
      throw new NotFoundException('Admin não encontrado');
    }

    const vinculos = await this.prisma.adminEscola.findMany({
      where: { admin_id: id },
    });

    for (const vinculo of vinculos) {
      const total = await this.prisma.adminEscola.count({
        where: { escola_id: vinculo.escola_id },
      });

      if (total <= 1) {
        throw new BadRequestException(
          'Não pode deletar o único admin da escola',
        );
      }
    }

    await this.prisma.adminEscola.deleteMany({
      where: { admin_id: id },
    });

    await this.prisma.admin.delete({
      where: { id },
    });

    return { mensagem: 'Admin deletado com sucesso' };
  }
}