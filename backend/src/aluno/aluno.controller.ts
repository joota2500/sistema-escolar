import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Delete,
  UseGuards,
  Req,
  ParseUUIDPipe,
} from '@nestjs/common';

import { AlunoService } from './aluno.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CreateAlunoDTO } from '../dto/criar-aluno.dto';
import { RequestComUsuario } from '../common/interfaces/request.interface';

@UseGuards(JwtAuthGuard)
@Controller('aluno')
export class AlunoController {
  constructor(private readonly service: AlunoService) {}

  // ==========================
  // CRIAR
  // ==========================
  @Post()
  async criar(@Body() body: CreateAlunoDTO, @Req() req: RequestComUsuario) {
    return this.service.criar(body, req.user);
  }

  // ==========================
  // LISTAR
  // ==========================
  @Get()
  async listar(@Req() req: RequestComUsuario) {
    return this.service.listar(req.user);
  }

  // ==========================
  // BUSCAR
  // ==========================
  @Get(':id')
  async buscar(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: RequestComUsuario,
  ) {
    return this.service.buscar(id, req.user);
  }

  // ==========================
  // DELETAR
  // ==========================
  @Delete(':id')
  async deletar(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: RequestComUsuario,
  ) {
    return this.service.deletar(id, req.user);
  }
}
