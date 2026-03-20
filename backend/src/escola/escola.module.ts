import { Module, forwardRef } from '@nestjs/common';

import { EscolaController } from './escola.controller';
import { EscolaService } from './escola.service';

import { PrismaService } from '../prisma/prisma.service';
import { ProfessorModule } from '../professor/professor.module';
import { RequestContextService } from '../common/context/request-context.service';

@Module({
  imports: [forwardRef(() => ProfessorModule)],
  controllers: [EscolaController],
  providers: [
    EscolaService,
    PrismaService,
    RequestContextService, // 🔥 NECESSÁRIO PRO PRISMA
  ],
  exports: [EscolaService],
})
export class EscolaModule {}
