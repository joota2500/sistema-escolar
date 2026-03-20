import {
  Controller,
  Post,
  Get,
  Body,
  Delete,
  Put,
  Param,
  UseGuards,
  Req,
  ParseUUIDPipe,
} from '@nestjs/common';

import { AdminService } from './admin.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RequestComUsuario } from '../common/interfaces/request.interface';

// ==============================
// DTOs
// ==============================
interface CriarAdminDTO {
  nome: string;
  email: string;
  senha: string;
}

interface AtualizarAdminDTO {
  nome?: string;
  email?: string;
}

interface VincularAdminDTO {
  admin_id: string;
  escola_id: string;
}

interface LoginDTO {
  email: string;
  senha: string;
}

@Controller('admin')
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  // ==============================
  // 🔓 LOGIN (NUNCA PROTEGER)
  // ==============================
  @Post('login')
  async login(@Body() dados: LoginDTO) {
    return this.adminService.login(dados);
  }

  // ==============================
  // 🔒 ROTAS PROTEGIDAS
  // ==============================

  @UseGuards(JwtAuthGuard)
  @Post()
  async criarAdmin(
    @Body() dados: CriarAdminDTO,
    @Req() req: RequestComUsuario,
  ) {
    return this.adminService.criarAdmin(dados, req.user);
  }

  @UseGuards(JwtAuthGuard)
  @Get()
  async listar(@Req() req: RequestComUsuario) {
    return this.adminService.listarAdmins(req.user);
  }

  @UseGuards(JwtAuthGuard)
  @Put(':id')
  async atualizar(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dados: AtualizarAdminDTO,
    @Req() req: RequestComUsuario,
  ) {
    return this.adminService.atualizarAdmin(id, dados, req.user);
  }

  @UseGuards(JwtAuthGuard)
  @Delete(':id')
  async deletar(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: RequestComUsuario,
  ) {
    return this.adminService.deletarAdmin(id, req.user);
  }

  @UseGuards(JwtAuthGuard)
  @Post('vincular')
  async vincular(
    @Body() dados: VincularAdminDTO,
    @Req() req: RequestComUsuario,
  ) {
    return this.adminService.vincularEscola(
      dados.admin_id,
      dados.escola_id,
      req.user,
    );
  }

  @UseGuards(JwtAuthGuard)
  @Delete('desvincular')
  async desvincular(
    @Body() dados: VincularAdminDTO,
    @Req() req: RequestComUsuario,
  ) {
    return this.adminService.desvincularAdmin(
      dados.admin_id,
      dados.escola_id,
      req.user,
    );
  }
}
