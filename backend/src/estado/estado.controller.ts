import { Controller, Get } from '@nestjs/common';
import { ESTADOS_BRASIL } from '../constants/estados';

@Controller('estado')
export class EstadoController {
  @Get()
  listarEstados() {
    return ESTADOS_BRASIL;
  }
}
