import { Request } from 'express';
import { UsuarioLogado } from './usuario-logado.interface';

export interface RequestComUsuario extends Request {
  user: UsuarioLogado;
}
