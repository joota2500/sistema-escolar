import {
  Controller,
  Post,
  Get,
  Put,
  Delete,
  Param,
  Body,
  ParseUUIDPipe,
  BadRequestException,
} from '@nestjs/common';

import { TurmaService } from './turma.service';

@Controller('turma')
export class TurmaController {
  constructor(private readonly turmaService: TurmaService) {}

  // ==========================
  // CRIAR
  // ==========================
  @Post()
  async criarTurma(@Body() dados: any) {
    return this.turmaService.criarTurma(dados);
  }

  // ==========================
  // LISTAR
  // ==========================
  @Get()
  async listarTurmas() {
    return this.turmaService.listarTurmas();
  }

  // ==========================
  // BUSCAR
  // ==========================
  @Get(':id')
  async buscarTurma(@Param('id', ParseUUIDPipe) id: string) {
    return this.turmaService.buscarTurma(id);
  }

  // ==========================
  // 🔥 PROFESSORES DA TURMA
  // ==========================
  @Get(':id/professores')
  async professores(@Param('id', ParseUUIDPipe) id: string) {
    return this.turmaService.buscarProfessoresDaTurma(id);
  }

  // ==========================
  // ATUALIZAR
  // ==========================
  @Put(':id')
  async atualizarTurma(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dados: any,
  ) {
    return this.turmaService.atualizarTurma(id, dados);
  }

  // ==========================
  // DELETAR
  // ==========================
  @Delete(':id')
  async deletarTurma(@Param('id', ParseUUIDPipe) id: string) {
    return this.turmaService.deletarTurma(id);
  }

  // ==========================
  // 🔗 VINCULAR PROFESSOR
  // ==========================
  @Post('vincular-professor')
  async vincularProfessor(@Body() body: any) {
    if (!body.turma_id || !body.professor_id) {
      throw new BadRequestException('Dados inválidos');
    }

    return this.turmaService.vincularProfessor({
      turma_id: body.turma_id,
      professor_id: body.professor_id,
      disciplina: body.disciplina,
    });
  }

  // ==========================
  // OBSERVAÇÃO
  // ==========================
  @Post('observacao')
  async criarObservacao(@Body() dados: any) {
    return this.turmaService.criarObservacao(dados);
  }

  // ==========================
  // HORÁRIO
  // ==========================
  @Post('horario')
  async criarHorario(@Body() dados: any) {
    return this.turmaService.criarHorario(dados);
  }
}
