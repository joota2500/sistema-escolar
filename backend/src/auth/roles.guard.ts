import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Request } from 'express';
import { UsuarioLogado } from '../common/interfaces/usuario-logado.interface';

interface RequestComUsuario extends Request {
  user: UsuarioLogado;
}

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const roles = this.reflector.get<string[]>('roles', context.getHandler());

    // sem roles → libera
    if (!roles) return true;

    const request = context.switchToHttp().getRequest<RequestComUsuario>();
    const user = request.user;

    if (!user) {
      throw new ForbiddenException('Usuário não autenticado');
    }

    const autorizado = roles.includes(user.role);

    if (!autorizado) {
      throw new ForbiddenException('Acesso negado por permissão');
    }

    return true;
  }
}
