import {
  Controller,
  Post,
  Get,
  Put,
  Delete,
  Body,
  Param,
  ParseUUIDPipe,
} from '@nestjs/common';

import { EscolaService } from './escola.service';
import { CriarEscolaDTO } from '../dto/criar-escola.dto';

@Controller('escola')
export class EscolaController {
  constructor(private readonly escolaService: EscolaService) {}

  @Post()
  criarEscola(@Body() dados: CriarEscolaDTO) {
    return this.escolaService.criarEscola(dados);
  }

  @Get()
  listarEscolas() {
    return this.escolaService.listarEscolas();
  }

  @Get(':id')
  buscarEscola(@Param('id', ParseUUIDPipe) id: string) {
    return this.escolaService.buscarEscola(id);
  }

  @Put(':id')
  atualizarEscola(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dados: Partial<CriarEscolaDTO>,
  ) {
    return this.escolaService.atualizarEscola(id, dados);
  }

  @Delete(':id')
  deletarEscola(@Param('id', ParseUUIDPipe) id: string) {
    return this.escolaService.deletarEscola(id);
  }

  @Get(':id/professores')
  listarProfessoresDaEscola(@Param('id', ParseUUIDPipe) id: string) {
    return this.escolaService.listarProfessoresDaEscola(id);
  }
  @Get(':id/status')
  async status(@Param('id') id: string) {
    return this.escolaService.statusEscola(id);
  }
}
