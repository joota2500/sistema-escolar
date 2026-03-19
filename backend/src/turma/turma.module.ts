import { Module } from '@nestjs/common';
import { TurmaController } from './turma.controller';
import { TurmaService } from './turma.service';
import { PrismaService } from '../prisma/prisma.service';

@Module({
  controllers: [TurmaController],
  providers: [TurmaService, PrismaService],
  exports: [TurmaService],
})
export class TurmaModule {}
