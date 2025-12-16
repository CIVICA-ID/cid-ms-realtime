import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { Logger } from '@nestjs/common';

async function bootstrap() {
  const logger = new Logger('Bootstrap');
  const app = await NestFactory.create(AppModule);
  
  // Enable CORS
  app.enableCors();
  
  // Global prefix
  app.setGlobalPrefix('api');
  
  const port = process.env.PORT || 3004;
  await app.listen(port);
  
  logger.log(`🚀 CID-MS-REALTIME is running on port ${port}`);
  logger.log(`📊 Health check available at /health`);
}
bootstrap();
