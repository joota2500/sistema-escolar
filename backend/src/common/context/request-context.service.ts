import { Injectable } from '@nestjs/common';
import { AsyncLocalStorage } from 'async_hooks';
import { UsuarioLogado } from '../interfaces/usuario-logado.interface';

type Store = {
  user?: UsuarioLogado;
};

@Injectable()
export class RequestContextService {
  private readonly asyncLocalStorage = new AsyncLocalStorage<Store>();

  run(callback: () => void) {
    this.asyncLocalStorage.run({}, callback);
  }

  setUser(user: UsuarioLogado) {
    const store = this.asyncLocalStorage.getStore();
    if (store) {
      store.user = user;
    }
  }

  getUser(): UsuarioLogado | null {
    return this.asyncLocalStorage.getStore()?.user ?? null;
  }
}
