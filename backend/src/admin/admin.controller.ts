import { Controller, Post, Get, Body, Delete, UseGuards } from '@nestjs/common';

import { AdminService } from './admin.service';
import { AuthGuard } from '@nestjs/passport';

@Controller('admin')
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  // 🔓 CRIAR ADMIN (liberado por enquanto)
  @Post()
  async criarAdmin(
    @Body() dados: { nome: string; email: string; senha: string },
  ) {
    return this.adminService.criarAdmin(dados);
  }

  // 🔓 LOGIN
  @Post('login')
  async login(@Body() dados: { email: string; senha: string }) {
    return this.adminService.login(dados);
  }

  // 🔒 PROTEGIDO
  @UseGuards(AuthGuard('jwt'))
  @Get()
  async listarAdmins() {
    return this.adminService.listarAdmins();
  }

  // 🔒 VINCULAR ADMIN À ESCOLA
  @UseGuards(AuthGuard('jwt'))
  @Post('vincular')
  async vincular(@Body() dados: { admin_id: string; escola_id: string }) {
    return this.adminService.vincularEscola(dados.admin_id, dados.escola_id);
  }
  @Delete('desvincular')
  async desvincular(@Body() dados: { admin_id: string; escola_id: string }) {
    return this.adminService.desvincularAdmin(dados.admin_id, dados.escola_id);
  }
}
