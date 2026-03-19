import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';

import { AuthService } from './auth.service';
import { JwtStrategy } from './jwt.strategy';
import { RolesGuard } from './roles.guard'; // 🔥 NOVO

@Module({
  imports: [
    JwtModule.register({
      secret: 'segredo_super_forte',
      signOptions: { expiresIn: '1d' },
    }),
  ],
  providers: [
    AuthService,
    JwtStrategy,
    RolesGuard, // 🔥 IMPORTANTE
  ],
  exports: [
    AuthService,
    JwtModule, // 🔥 exporta também (boa prática)
  ],
})
export class AuthModule {}
