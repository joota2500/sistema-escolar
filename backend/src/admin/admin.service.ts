import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import * as bcrypt from 'bcrypt';
import { AuthService } from '../auth/auth.service';

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

  private removerSenha(admin: any) {
    const { senha: _senha, ...resto } = admin;
    return resto;
  }

  // =============================
  // CRIAR ADMIN
  // =============================
  async criarAdmin(dados: { nome: string; email: string; senha: string }) {
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

    const senhaHash = await bcrypt.hash(String(senha), 10);

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
  // LOGIN ADMIN 🔐
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

    const senhaValida = await bcrypt.compare(
      String(senha),
      String(admin.senha),
    );

    if (!senhaValida) {
      throw new BadRequestException('Credenciais inválidas');
    }

    const tokenData = this.authService.gerarToken({
      id: admin.id,
      nome: admin.nome,
      role: admin.role,
    });

    return {
      sucesso: true,
      ...tokenData,
    };
  }

  // =============================
  // LISTAR ADMINS
  // =============================
  async listarAdmins() {
    const admins = await this.prisma.admin.findMany({
      orderBy: { nome: 'asc' },
    });

    return admins.map((admin) => this.removerSenha(admin));
  }

  // =============================
  // VINCULAR ADMIN À ESCOLA
  // =============================
  async vincularEscola(admin_id: string, escola_id: string) {
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
      throw new BadRequestException('Admin já vinculado a essa escola');
    }

    const total = await this.prisma.adminEscola.count({
      where: { escola_id },
    });

    if (total >= 2) {
      throw new BadRequestException('Essa escola já possui 2 administradores');
    }

    return this.prisma.adminEscola.create({
      data: {
        admin_id,
        escola_id,
      },
    });
  }

  // =============================
  // DESVINCULAR ADMIN
  // =============================
  async desvincularAdmin(admin_id: string, escola_id: string) {
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
        'A escola deve ter pelo menos 1 administrador',
      );
    }

    await this.prisma.adminEscola.delete({
      where: { id: vinculo.id },
    });

    return { mensagem: 'Admin removido da escola com sucesso' };
  }
}
