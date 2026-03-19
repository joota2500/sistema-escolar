import { Module } from '@nestjs/common';

import { AppController } from './app.controller';
import { AppService } from './app.service';

import { EscolaModule } from './escola/escola.module';
import { ProfessorModule } from './professor/professor.module';
import { TurmaModule } from './turma/turma.module';
import { DisciplinaModule } from './disciplina/disciplina.module';
import { EstadoModule } from './estado/estado.module';
import { AdminModule } from './admin/admin.module';
import { AlunoModule } from './aluno/aluno.module';

@Module({
  imports: [
    EscolaModule,
    ProfessorModule,
    TurmaModule,
    DisciplinaModule,
    EstadoModule,
    AdminModule,
    AlunoModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
