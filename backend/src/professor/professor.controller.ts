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
  Req,
} from '@nestjs/common';

import { ProfessorService } from './professor.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CriarProfessorDTO } from '../dto/criar-professor.dto';
import { RequestComUsuario } from '../common/interfaces/request.interface';

@UseGuards(JwtAuthGuard)
@Controller('professor')
export class ProfessorController {
  constructor(private readonly professorService: ProfessorService) {}

  @Post('login')
  async login(@Body() dados: { cpf: string; senha: string }) {
    return this.professorService.login(dados);
  }

  @Post()
  async cadastrar(
    @Body() dados: CriarProfessorDTO,
    @Req() req: RequestComUsuario,
  ) {
    return this.professorService.cadastrarProfessor(dados, req.user);
  }

  @Get()
  async listar(@Req() req: RequestComUsuario) {
    return this.professorService.listarProfessores(req.user);
  }

  @Get(':id')
  async buscar(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: RequestComUsuario,
  ) {
    return this.professorService.buscarProfessor(id, req.user);
  }

  @Put(':id')
  async atualizar(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dados: Partial<CriarProfessorDTO>,
    @Req() req: RequestComUsuario,
  ) {
    return this.professorService.atualizarProfessor(id, dados, req.user);
  }

  @Delete(':id')
  async deletar(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: RequestComUsuario,
  ) {
    return this.professorService.deletarProfessor(id, req.user);
  }

  @Post('alterar-senha')
  async alterarSenha(
    @Body() dados: { cpf: string; senhaAtual: string; novaSenha: string },
  ) {
    return this.professorService.alterarSenha(dados);
  }
}
