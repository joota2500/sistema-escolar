import {
  Injectable,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';
import { UsuarioLogado } from '../common/interfaces/usuario-logado.interface';

@Injectable()
export class SistemaService {
  constructor(private prisma: PrismaService) {}

  // =============================
  // 🔧 MANUTENÇÃO GLOBAL (ON/OFF)
  // =============================
  async setManutencaoGlobal(
    status: boolean,
    motivo: string | undefined,
    user: UsuarioLogado,
  ) {
    if (user.role !== 'superadmin') {
      throw new ForbiddenException('Apenas superadmin');
    }

    if (status && !motivo) {
      throw new BadRequestException(
        'Motivo é obrigatório ao ativar manutenção',
      );
    }

    const resultado = await this.prisma.sistema.upsert({
      where: { id: 'global' },
      update: {
        manutencao_global: status,
        motivo: status ? motivo : null,
        atualizado_em: new Date(),
      },
      create: {
        id: 'global',
        manutencao_global: status,
        motivo: status ? motivo : null,
      },
    });

    return resultado;
  }

  // =============================
  // 📊 STATUS GLOBAL
  // =============================
  async status() {
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

    return {
      manutencao_global: sistema.manutencao_global,
      motivo: sistema.motivo,
      atualizado_em: sistema.atualizado_em,
      status: sistema.manutencao_global
        ? '🔴 Sistema em manutenção'
        : '🟢 Sistema operacional',
    };
  }
}
