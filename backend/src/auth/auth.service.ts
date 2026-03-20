import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma/prisma.service';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  constructor(
    private readonly jwtService: JwtService,
    private readonly prisma: PrismaService,
  ) {}

  async login(email: string, senha: string) {
    const user = await this.prisma.admin.findUnique({
      where: { email },
      include: {
        escolas: true,
      },
    });

    if (!user) {
      throw new UnauthorizedException('Usuário não encontrado');
    }

    const senhaValida = await bcrypt.compare(senha, user.senha);

    if (!senhaValida) {
      throw new UnauthorizedException('Senha incorreta');
    }

    const escola_id = user.escolas[0]?.escola_id ?? null;

    const payload = {
      sub: user.id,
      nome: user.nome,
      role: user.role,
      escola_id,
    };

    return {
      access_token: this.jwtService.sign(payload),
      primeiro_acesso: user.primeiro_acesso,
      usuario: {
        id: user.id,
        nome: user.nome,
        role: user.role,
        escola_id,
      },
    };
  }

  async trocarSenha(userId: string, novaSenha: string) {
    const senhaHash = await bcrypt.hash(novaSenha, 10);

    await this.prisma.admin.update({
      where: { id: userId },
      data: {
        senha: senhaHash,
        primeiro_acesso: false,
      },
    });

    return { sucesso: true };
  }
  gerarToken(usuario: {
    id: string;
    nome: string;
    role: string;
    escola_id?: string | null;
  }) {
    const payload = {
      sub: usuario.id,
      nome: usuario.nome,
      role: usuario.role,
      escola_id: usuario.escola_id ?? null,
    };

    return {
      access_token: this.jwtService.sign(payload),
      usuario,
    };
  }
}
