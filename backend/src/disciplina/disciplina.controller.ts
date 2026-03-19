import { Controller, Get } from '@nestjs/common';
import { DisciplinaService } from './disciplina.service';

@Controller('disciplina')
export class DisciplinaController {
  constructor(private readonly disciplinaService: DisciplinaService) {}

  @Get()
  listar() {
    return this.disciplinaService.listarDisciplinas();
  }
}
