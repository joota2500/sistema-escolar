import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';

export interface UsuarioPayload {
  id: string;
  nome: string;
  role: string;
}

@Injectable()
export class AuthService {
  constructor(private readonly jwtService: JwtService) {}

  gerarToken(usuario: UsuarioPayload) {
    const payload = {
      sub: usuario.id,
      nome: usuario.nome,
      role: usuario.role,
    };

    const token = this.jwtService.sign(payload);

    return {
      access_token: token,
      usuario: {
        id: usuario.id,
        nome: usuario.nome,
        role: usuario.role,
      },
    };
  }
}
