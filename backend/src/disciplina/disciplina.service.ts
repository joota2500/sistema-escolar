import { Injectable } from '@nestjs/common';
import { DISCIPLINAS } from '../constants/disciplinas';

@Injectable()
export class DisciplinaService {
  listarDisciplinas() {
    return DISCIPLINAS;
  }
}
