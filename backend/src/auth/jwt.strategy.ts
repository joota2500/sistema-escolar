import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';

import { PrismaService } from '../prisma/prisma.service';
import { UsuarioLogado } from '../common/interfaces/usuario-logado.interface';

interface JwtPayload {
  sub: string;
  nome: string;
  role: string;
  escola_id?: string | null;
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy, 'jwt') {
  constructor(private readonly prisma: PrismaService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      secretOrKey: process.env.JWT_SECRET || 'segredo_super_forte',
      ignoreExpiration: false,
    });

    console.log('✅ JwtStrategy registrada');
  }

  async validate(payload: JwtPayload): Promise<UsuarioLogado> {
    try {
      let sistema = await this.prisma.sistema.findUnique({
        where: { id: 'global' },
      });

      if (!sistema) {
        sistema = await this.prisma.sistema.create({
          data: {
            id: 'global',
            manutencao_global: false,
            motivo: null,
          },
        });
      }

      if (sistema.manutencao_global && payload.role !== 'superadmin') {
        throw new UnauthorizedException(
          sistema.motivo || 'Sistema em manutenção',
        );
      }

      if (payload.escola_id) {
        const escola = await this.prisma.escola.findUnique({
          where: { id: payload.escola_id },
          select: {
            ativa: true,
            motivo_bloqueio: true,
            modo_manutencao: true,
          },
        });

        if (!escola) {
          throw new UnauthorizedException('Acesso inválido');
        }

        if (!escola.ativa) {
          throw new UnauthorizedException(
            escola.motivo_bloqueio || 'Escola bloqueada',
          );
        }

        if (escola.modo_manutencao && payload.role !== 'superadmin') {
          throw new UnauthorizedException('Escola em manutenção');
        }
      }

      // 🔥 AQUI ESTÁ A CORREÇÃO PRINCIPAL
      return {
        id: payload.sub, // ✅ PADRÃO CORRETO
        nome: payload.nome,
        role: payload.role,
        escola_id: payload.escola_id ?? null,
      };
    } catch (error: any) {
      throw new UnauthorizedException(error?.message || 'Token inválido');
    }
  }
}
