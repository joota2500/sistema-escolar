import {
  Controller,
  Post,
  Get,
  Delete,
  Put,
  Body,
  Param,
  ParseUUIDPipe,
  UseGuards,
} from '@nestjs/common';

import { ProfessorService } from './professor.service';
import { AuthGuard } from '@nestjs/passport';

interface ProfessorDTO {
  nome: string;
  cpf: string;
  senha: string;
  escola_id: string;
  email?: string;
  disciplina?: string;
  telefone?: string;
}

@Controller('professor')
export class ProfessorController {
  constructor(private readonly professorService: ProfessorService) {}

  @Post('login')
  async login(@Body() dados: { cpf: string; senha: string }) {
    return this.professorService.login(dados);
  }

  @UseGuards(AuthGuard('jwt'))
  @Post('alterar-senha')
  async alterarSenha(
    @Body() dados: { cpf: string; senhaAtual: string; novaSenha: string },
  ) {
    return this.professorService.alterarSenha(dados);
  }

  @UseGuards(AuthGuard('jwt'))
  @Post()
  async cadastrarProfessor(@Body() dados: ProfessorDTO) {
    return this.professorService.cadastrarProfessor(dados);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get()
  async listarProfessores() {
    return this.professorService.listarProfessores();
  }

  @UseGuards(AuthGuard('jwt'))
  @Get(':id')
  async buscarProfessor(@Param('id', ParseUUIDPipe) id: string) {
    return this.professorService.buscarProfessor(id);
  }

  @UseGuards(AuthGuard('jwt'))
  @Put(':id')
  async atualizarProfessor(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dados: Partial<ProfessorDTO>,
  ) {
    return this.professorService.atualizarProfessor(id, dados);
  }

  @UseGuards(AuthGuard('jwt'))
  @Delete(':id')
  async deletarProfessor(@Param('id', ParseUUIDPipe) id: string) {
    return this.professorService.deletarProfessor(id);
  }
}
