import { Module, forwardRef } from '@nestjs/common';

import { EscolaController } from './escola.controller';
import { EscolaService } from './escola.service';

import { PrismaService } from '../prisma/prisma.service';
import { ProfessorModule } from '../professor/professor.module';

@Module({
  imports: [forwardRef(() => ProfessorModule)],
  controllers: [EscolaController],
  providers: [EscolaService, PrismaService],
  exports: [EscolaService],
})
export class EscolaModule {}
