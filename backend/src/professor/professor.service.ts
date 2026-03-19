import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import * as bcrypt from 'bcrypt';
import { AuthService } from '../auth/auth.service';

interface LoginDTO {
  cpf: string;
  senha: string;
}

interface ProfessorDTO {
  nome: string;
  cpf: string;
  senha: string;
  escola_id: string;
  email?: string;
  disciplina?: string;
  telefone?: string;
}

@Injectable()
export class ProfessorService {
  constructor(
    private prisma: PrismaService,
    private authService: AuthService,
  ) {}

  // 🔥 FORMATADOR (SEM ERRO DE ESLINT)
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

  async cadastrarProfessor(dados: ProfessorDTO) {
    const { nome, cpf, senha, escola_id, email, disciplina, telefone } = dados;

    if (!nome || !cpf || !senha || !escola_id) {
      throw new BadRequestException('Dados obrigatórios faltando');
    }

    const cpfExistente = await this.prisma.professor.findUnique({
      where: { cpf },
    });

    if (cpfExistente) {
      throw new BadRequestException('CPF já cadastrado');
    }

    const escola = await this.prisma.escola.findUnique({
      where: { id: escola_id },
    });

    if (!escola) {
      throw new NotFoundException('Escola não encontrada');
    }

    const senhaHash = await bcrypt.hash(String(senha), 10);

    const professor = await this.prisma.professor.create({
      data: {
        nome,
        cpf,
        email,
        senha: senhaHash,
        disciplina,
        telefone,
        escola_id,
        status: 'ativo',
      },
    });

    return this.formatarProfessor(professor);
  }

  async login(dados: LoginDTO) {
    const { cpf, senha } = dados;

    if (!cpf || !senha) {
      throw new BadRequestException('CPF e senha obrigatórios');
    }

    const professor = await this.prisma.professor.findUnique({
      where: { cpf },
    });

    if (!professor) {
      throw new BadRequestException('CPF ou senha inválidos');
    }

    const senhaValida = await bcrypt.compare(
      String(senha),
      String(professor.senha),
    );

    if (!senhaValida) {
      throw new BadRequestException('CPF ou senha inválidos');
    }

    const token = this.authService.gerarToken({
      id: professor.id,
      nome: professor.nome,
      role: 'professor',
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

  async listarProfessores() {
    const professores = await this.prisma.professor.findMany({
      include: { escola: true },
      orderBy: { nome: 'asc' },
    });

    return professores.map((prof) => this.formatarProfessor(prof));
  }

  async buscarProfessor(id: string) {
    const professor = await this.prisma.professor.findUnique({
      where: { id },
      include: { escola: true },
    });

    if (!professor) {
      throw new NotFoundException('Professor não encontrado');
    }

    return this.formatarProfessor(professor);
  }

  async alterarSenha(dados: {
    cpf: string;
    senhaAtual: string;
    novaSenha: string;
  }) {
    const { cpf, senhaAtual, novaSenha } = dados;

    if (!cpf || !senhaAtual || !novaSenha) {
      throw new BadRequestException('Dados incompletos');
    }

    const professor = await this.prisma.professor.findUnique({
      where: { cpf },
    });

    if (!professor) {
      throw new NotFoundException('Professor não encontrado');
    }

    const senhaValida = await bcrypt.compare(
      String(senhaAtual),
      String(professor.senha),
    );

    if (!senhaValida) {
      throw new BadRequestException('Senha atual inválida');
    }

    const novaSenhaHash = await bcrypt.hash(String(novaSenha), 10);

    await this.prisma.professor.update({
      where: { id: professor.id },
      data: { senha: novaSenhaHash },
    });

    return { mensagem: 'Senha atualizada com sucesso' };
  }

  async atualizarProfessor(id: string, dados: Partial<ProfessorDTO>) {
    const professor = await this.prisma.professor.findUnique({
      where: { id },
    });

    if (!professor) {
      throw new NotFoundException('Professor não encontrado');
    }

    const atualizado = await this.prisma.professor.update({
      where: { id },
      data: {
        ...dados,
        senha: undefined,
      },
    });

    return this.formatarProfessor(atualizado);
  }

  async deletarProfessor(id: string) {
    const professor = await this.prisma.professor.findUnique({
      where: { id },
    });

    if (!professor) {
      throw new NotFoundException('Professor não encontrado');
    }

    await this.prisma.professor.delete({
      where: { id },
    });

    return { mensagem: 'Professor deletado com sucesso' };
  }
}
