//deploy trigger
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // ===============================
  // CORS
  // ===============================
  app.enableCors({
    origin: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true,
  });

  // ===============================
  // PREFIXO GLOBAL (OPCIONAL)
  // ===============================
  // app.setGlobalPrefix('api');

  // ===============================
  // PORTA (IMPORTANTE PRA RAILWAY)
  // ===============================
  const port = process.env.PORT || 3000;

  await app.listen(port, '0.0.0.0');

  console.log(`🚀 Servidor rodando na porta ${port}`);
}

bootstrap().catch(console.error);
