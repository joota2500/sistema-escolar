import { Controller, Get, Post, Body, Param, Delete } from '@nestjs/common';
import { AlunoService } from './aluno.service';

@Controller('aluno')
export class AlunoController {
  constructor(private readonly service: AlunoService) {}

  // 🔥 CRIAR
  @Post()
  async criar(@Body() body: any) {
    return await this.service.criar(body);
  }

  // 🔥 LISTAR
  @Get()
  async listar() {
    return await this.service.listar();
  }

  // 🔥 BUSCAR
  @Get(':id')
  async buscar(@Param('id') id: string) {
    return await this.service.buscar(id);
  }

  // 🔥 DELETAR
  @Delete(':id')
  async deletar(@Param('id') id: string) {
    return await this.service.deletar(id);
  }
}
