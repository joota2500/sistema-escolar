import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
} from '@nestjs/common';
import { Observable } from 'rxjs';

import { RequestContextService } from '../context/request-context.service';
import { UsuarioLogado } from '../interfaces/usuario-logado.interface';
import { Request } from 'express';

interface RequestComUsuario extends Request {
  user?: UsuarioLogado;
}

@Injectable()
export class RequestContextInterceptor implements NestInterceptor {
  constructor(private readonly contextService: RequestContextService) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest<RequestComUsuario>();

    return new Observable((subscriber) => {
      this.contextService.run(() => {
        if (request.user) {
          this.contextService.setUser(request.user);
        }

        next.handle().subscribe({
          next: (value) => subscriber.next(value),
          error: (err) => subscriber.error(err),
          complete: () => subscriber.complete(),
        });
      });
    });
  }
}
