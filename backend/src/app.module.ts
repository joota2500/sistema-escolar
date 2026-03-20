import { Module } from '@nestjs/common';

import { AppController } from './app.controller';
import { AppService } from './app.service';

// 🔐 AUTH
import { AuthModule } from './auth/auth.module';

// 📦 DOMÍNIO
import { EscolaModule } from './escola/escola.module';
import { ProfessorModule } from './professor/professor.module';
import { TurmaModule } from './turma/turma.module';
import { DisciplinaModule } from './disciplina/disciplina.module';
import { EstadoModule } from './estado/estado.module';
import { AdminModule } from './admin/admin.module';
import { AlunoModule } from './aluno/aluno.module';

// 🔥 CORE GLOBAL (IMPORTANTE VIR PRIMEIRO)
import { ContextModule } from './common/context/context.module';
import { PrismaModule } from './prisma/prisma.module';

import { APP_INTERCEPTOR } from '@nestjs/core';
import { RequestContextInterceptor } from './common/interceptors/request-context.interceptor';

@Module({
  imports: [
    // 🔥 CORE (GLOBAL)
    PrismaModule,
    ContextModule,

    // 🔐 AUTH
    AuthModule,

    // 📦 MÓDULOS DO SISTEMA
    EscolaModule,
    ProfessorModule,
    TurmaModule,
    DisciplinaModule,
    EstadoModule,
    AdminModule,
    AlunoModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,

    // 🔥 INTERCEPTOR GLOBAL (OBRIGATÓRIO PRO CONTEXTO)
    {
      provide: APP_INTERCEPTOR,
      useClass: RequestContextInterceptor,
    },
  ],
})
export class AppModule {}
