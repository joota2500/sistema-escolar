import { Controller, Put, Body, Req, Get, UseGuards } from '@nestjs/common';
import { SistemaService } from './sistema.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RequestComUsuario } from '../common/interfaces/request.interface';

@UseGuards(JwtAuthGuard)
@Controller('sistema')
export class SistemaController {
  constructor(private service: SistemaService) {}

  @Put('manutencao')
  setManutencao(
    @Body() body: { status: boolean; motivo: string },
    @Req() req: RequestComUsuario,
  ) {
    return this.service.setManutencaoGlobal(body.status, body.motivo, req.user);
  }

  @Get()
  status() {
    return this.service.status();
  }
}
