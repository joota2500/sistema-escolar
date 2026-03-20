import 'dotenv/config';
import {
  Injectable,
  OnModuleInit,
  OnModuleDestroy,
  ForbiddenException,
} from '@nestjs/common';

import { PrismaClient } from '@prisma/client';
import { RequestContextService } from '../common/context/request-context.service';
import { UsuarioLogado } from '../common/interfaces/usuario-logado.interface';

@Injectable()
export class PrismaService
  extends PrismaClient
  implements OnModuleInit, OnModuleDestroy
{
  constructor(private readonly context: RequestContextService) {
    super({
      log: ['error', 'warn'],
    });
  }

  async onModuleInit() {
    await this.$connect();

    const useMiddleware = (this as any).$use.bind(this);

    useMiddleware(async (params: any, next: any) => {
      let user: UsuarioLogado | null = null;

      try {
        user = this.context.getUser();
      } catch {
        user = null;
      }

      // 🔓 LIBERA
      if (!user || user.role === 'superadmin') {
        return next(params);
      }

      // 🔥 BLOQUEIO
      if (user.escola_id) {
        const escola = await this.escola.findUnique({
          where: { id: user.escola_id },
          select: {
            ativa: true,
            modo_manutencao: true,
          },
        });

        if (!escola) {
          throw new ForbiddenException('Escola inválida');
        }

        if (!escola.ativa) {
          throw new ForbiddenException('Escola bloqueada');
        }

        if (escola.modo_manutencao) {
          throw new ForbiddenException('Escola em manutenção');
        }
      }

      // 🔥 MULTI-TENANT
      const modelsComEscola = [
        'Professor',
        'Turma',
        'Horario',
        'ObservacaoTurma',
      ];

      const model: string =
        typeof params.model === 'string' ? params.model : '';

      if (modelsComEscola.includes(model)) {
        params.args = params.args || {};
        params.args.where = params.args.where || {};

        params.args.where = {
          ...params.args.where,
          escola_id: user.escola_id,
        };
      }

      return next(params);
    });
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}
