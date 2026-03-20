import {
  Controller,
  Post,
  Get,
  Put,
  Delete,
  Body,
  Param,
  ParseUUIDPipe,
  UseGuards,
  Req,
  BadRequestException,
} from '@nestjs/common';

import { EscolaService } from './escola.service';
import { CriarEscolaDTO } from '../dto/criar-escola.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RequestComUsuario } from '../common/interfaces/request.interface';

@UseGuards(JwtAuthGuard)
@Controller('escola')
export class EscolaController {
  constructor(private readonly escolaService: EscolaService) {}

  // =============================
  // 🏫 CRIAR
  // =============================
  @Post()
  criarEscola(@Body() dados: CriarEscolaDTO, @Req() req: RequestComUsuario) {
    return this.escolaService.criarEscola(dados, req.user);
  }

  // =============================
  // 📋 LISTAR
  // =============================
  @Get()
  listarEscolas(@Req() req: RequestComUsuario) {
    return this.escolaService.listarEscolas(req.user);
  }

  // =============================
  // 🔍 BUSCAR
  // =============================
  @Get(':id')
  buscarEscola(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: RequestComUsuario,
  ) {
    return this.escolaService.buscarEscola(id, req.user);
  }

  // =============================
  // ✏️ ATUALIZAR
  // =============================
  @Put(':id')
  atualizarEscola(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dados: Partial<CriarEscolaDTO>,
    @Req() req: RequestComUsuario,
  ) {
    return this.escolaService.atualizarEscola(id, dados, req.user);
  }

  // =============================
  // ❌ DELETAR
  // =============================
  @Delete(':id')
  deletarEscola(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: RequestComUsuario,
  ) {
    return this.escolaService.deletarEscola(id, req.user);
  }

  // =============================
  // 👨‍🏫 PROFESSORES
  // =============================
  @Get(':id/professores')
  listarProfessoresDaEscola(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: RequestComUsuario,
  ) {
    return this.escolaService.listarProfessoresDaEscola(id, req.user);
  }

  // =============================
  // 📊 STATUS
  // =============================
  @Get(':id/status')
  status(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: RequestComUsuario,
  ) {
    return this.escolaService.statusEscola(id, req.user);
  }

  // =============================
  // 🔓 ATIVAR ESCOLA
  // =============================
  @Put(':id/ativar')
  ativar(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: RequestComUsuario,
  ) {
    return this.escolaService.ativarEscola(id, req.user);
  }

  // =============================
  // 🔒 DESATIVAR ESCOLA
  // =============================
  @Put(':id/desativar')
  desativar(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() body: { motivo: string },
    @Req() req: RequestComUsuario,
  ) {
    if (!body?.motivo) {
      throw new BadRequestException('Motivo obrigatório');
    }

    return this.escolaService.desativarEscola(id, body.motivo, req.user);
  }

  // =============================
  // 🔧 MANUTENÇÃO
  // =============================
  @Put(':id/manutencao')
  manutencao(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() body: { status: boolean },
    @Req() req: RequestComUsuario,
  ) {
    if (typeof body?.status !== 'boolean') {
      throw new BadRequestException('Status deve ser boolean');
    }

    return this.escolaService.manutencaoEscola(id, body.status, req.user);
  }
}
