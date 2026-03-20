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
  UseGuards,
  Req,
} from '@nestjs/common';

import { TurmaService } from './turma.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CriarTurmaDTO } from '../dto/criar-turma.dto';
import { RequestComUsuario } from '../common/interfaces/request.interface';

@UseGuards(JwtAuthGuard)
@Controller('turma')
export class TurmaController {
  constructor(private readonly turmaService: TurmaService) {}

  @Post()
  async criarTurma(
    @Body() dados: CriarTurmaDTO,
    @Req() req: RequestComUsuario,
  ) {
    return this.turmaService.criarTurma(dados, req.user);
  }

  @Get()
  async listarTurmas(@Req() req: RequestComUsuario) {
    return this.turmaService.listarTurmas(req.user);
  }

  @Get(':id')
  async buscarTurma(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: RequestComUsuario,
  ) {
    return this.turmaService.buscarTurma(id, req.user);
  }

  @Get(':id/professores')
  async professores(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: RequestComUsuario,
  ) {
    return this.turmaService.buscarProfessoresDaTurma(id, req.user);
  }

  @Put(':id')
  async atualizarTurma(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dados: Partial<CriarTurmaDTO>,
    @Req() req: RequestComUsuario,
  ) {
    return this.turmaService.atualizarTurma(id, dados, req.user);
  }

  @Delete(':id')
  async deletarTurma(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: RequestComUsuario,
  ) {
    return this.turmaService.deletarTurma(id, req.user);
  }

  @Post('vincular-professor')
  async vincularProfessor(
    @Body()
    body: {
      turma_id: string;
      professor_id: string;
      disciplina?: string;
    },
    @Req() req: RequestComUsuario,
  ) {
    if (!body.turma_id || !body.professor_id) {
      throw new BadRequestException('Dados inválidos');
    }

    return this.turmaService.vincularProfessor(body, req.user);
  }

  @Post('observacao')
  async criarObservacao(
    @Body()
    dados: {
      turma_id: string;
      professor_id: string;
      observacao: string;
    },
  ) {
    return this.turmaService.criarObservacao(dados);
  }

  @Post('horario')
  async criarHorario(
    @Body()
    dados: {
      turma_id: string;
      professor_id: string;
      disciplina: string;
      dia_semana: string;
      hora_inicio: string;
      hora_fim: string;
    },
  ) {
    return this.turmaService.criarHorario(dados);
  }
}
