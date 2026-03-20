import { Module, forwardRef } from '@nestjs/common';

import { ProfessorController } from './professor.controller';
import { ProfessorService } from './professor.service';

import { EscolaModule } from '../escola/escola.module';
import { PrismaService } from '../prisma/prisma.service';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [forwardRef(() => EscolaModule), AuthModule],
  controllers: [ProfessorController],
  providers: [ProfessorService, PrismaService],
  exports: [ProfessorService],
})
export class ProfessorModule {}
