import {
  Injectable,
  BadRequestException,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import * as bcrypt from 'bcrypt';
import { AuthService } from '../auth/auth.service';
import { CriarProfessorDTO } from '../dto/criar-professor.dto';
import { UsuarioLogado } from '../common/interfaces/usuario-logado.interface';

@Injectable()
export class ProfessorService {
  constructor(
    private prisma: PrismaService,
    private authService: AuthService,
  ) {}

  private formatarProfessor(prof: any) {
    return {
      id: prof.id,
      nome: prof.nome,
      cpf: prof.cpf,
      email: prof.email,
      disciplina: prof.disciplina,
      telefone: prof.telefone,
      escola_id: prof.escola_id,
      status: prof.status,
    };
  }

  private validarAcesso(user: UsuarioLogado, escola_id: string) {
    if (user.role === 'superadmin') return;

    if (user.escola_id !== escola_id) {
      throw new ForbiddenException('Acesso negado');
    }
  }

  // ==========================
  // CRIAR
  // ==========================
  async cadastrarProfessor(dados: CriarProfessorDTO, user: UsuarioLogado) {
    if (!dados.nome || !dados.cpf || !dados.senha) {
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

    const cpfExistente = await this.prisma.professor.findUnique({
      where: { cpf: dados.cpf },
    });

    if (cpfExistente) {
      throw new BadRequestException('CPF já cadastrado');
    }

    const senhaHash = await bcrypt.hash(dados.senha, 10);

    const professor = await this.prisma.professor.create({
      data: {
        nome: dados.nome,
        cpf: dados.cpf,
        email: dados.email,
        senha: senhaHash,
        disciplina: dados.disciplina,
        telefone: dados.telefone,
        escola_id: dados.escola_id,
        status: 'ativo',
      },
    });

    return this.formatarProfessor(professor);
  }

  // ==========================
  // LOGIN (🔥 MELHORADO)
  // ==========================
  async login(dados: { cpf: string; senha: string }) {
    const professor = await this.prisma.professor.findUnique({
      where: { cpf: dados.cpf },
    });

    if (!professor) {
      throw new BadRequestException('Credenciais inválidas');
    }

    const senhaValida = await bcrypt.compare(dados.senha, professor.senha);

    if (!senhaValida) {
      throw new BadRequestException('Credenciais inválidas');
    }

    const token = this.authService.gerarToken({
      id: professor.id,
      nome: professor.nome,
      role: 'professor',
      escola_id: professor.escola_id, // 🔥 ESSENCIAL
    });

    return {
      sucesso: true,
      access_token: token.access_token,
      usuario: {
        ...this.formatarProfessor(professor),
        role: 'professor',
      },
    };
  }

  // ==========================
  // LISTAR
  // ==========================
  async listarProfessores(user: UsuarioLogado) {
    if (user.role === 'superadmin') {
      const professores = await this.prisma.professor.findMany({
        orderBy: { nome: 'asc' },
      });

      return professores.map((p) => this.formatarProfessor(p));
    }

    const professores = await this.prisma.professor.findMany({
      where: {
        ...(user.escola_id && { escola_id: user.escola_id }),
      },
      orderBy: { nome: 'asc' },
    });

    return professores.map((p) => this.formatarProfessor(p));
  }

  // ==========================
  // BUSCAR
  // ==========================
  async buscarProfessor(id: string, user: UsuarioLogado) {
    const professor = await this.prisma.professor.findUnique({
      where: { id },
    });

    if (!professor) {
      throw new NotFoundException('Professor não encontrado');
    }

    this.validarAcesso(user, professor.escola_id);

    return this.formatarProfessor(professor);
  }

  // ==========================
  // ATUALIZAR
  // ==========================
  async atualizarProfessor(
    id: string,
    dados: Partial<CriarProfessorDTO>,
    user: UsuarioLogado,
  ) {
    const professor = await this.prisma.professor.findUnique({
      where: { id },
    });

    if (!professor) {
      throw new NotFoundException('Professor não encontrado');
    }

    this.validarAcesso(user, professor.escola_id);

    const atualizado = await this.prisma.professor.update({
      where: { id },
      data: {
        nome: dados.nome,
        email: dados.email,
        disciplina: dados.disciplina,
        telefone: dados.telefone,
      },
    });

    return this.formatarProfessor(atualizado);
  }

  // ==========================
  // DELETAR
  // ==========================
  async deletarProfessor(id: string, user: UsuarioLogado) {
    const professor = await this.prisma.professor.findUnique({
      where: { id },
    });

    if (!professor) {
      throw new NotFoundException('Professor não encontrado');
    }

    this.validarAcesso(user, professor.escola_id);

    await this.prisma.professor.delete({
      where: { id },
    });

    return { mensagem: 'Professor deletado com sucesso' };
  }

  // ==========================
  // SENHA
  // ==========================
  async alterarSenha(dados: {
    cpf: string;
    senhaAtual: string;
    novaSenha: string;
  }) {
    const professor = await this.prisma.professor.findUnique({
      where: { cpf: dados.cpf },
    });

    if (!professor) {
      throw new NotFoundException('Professor não encontrado');
    }

    const senhaValida = await bcrypt.compare(dados.senhaAtual, professor.senha);

    if (!senhaValida) {
      throw new BadRequestException('Senha atual inválida');
    }

    const novaSenhaHash = await bcrypt.hash(dados.novaSenha, 10);

    await this.prisma.professor.update({
      where: { id: professor.id },
      data: { senha: novaSenhaHash },
    });

    return { mensagem: 'Senha atualizada com sucesso' };
  }
}
