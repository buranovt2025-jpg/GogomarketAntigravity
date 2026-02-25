import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
    const app = await NestFactory.create(AppModule);

    // Global prefix
    app.setGlobalPrefix('api', { exclude: ['/'] });

    // Enable CORS
    app.enableCors({
        origin: true,
        credentials: true,
    });

    // Global validation pipe
    app.useGlobalPipes(
        new ValidationPipe({
            whitelist: true,
            forbidNonWhitelisted: true,
            transform: true,
        }),
    );

    // Swagger documentation
    const config = new DocumentBuilder()
        .setTitle('GOGOMARKET API')
        .setDescription('Social E-Commerce Platform API Documentation')
        .setVersion('1.0')
        .addBearerAuth()
        .addTag('auth', 'Authentication endpoints')
        .addTag('users', 'User management')
        .addTag('sellers', 'Seller operations')
        .addTag('products', 'Product management')
        .addTag('orders', 'Order management')
        .addTag('stories', 'Stories management')
        .addTag('reels', 'Reels management')
        .addTag('chat', 'Chat operations')
        .addTag('payments', 'Payment processing')
        .build();

    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('api/docs', app, document);

    const port = process.env.PORT || 3000;
    await app.listen(port);

    console.log(`
🚀 GOGOMARKET Backend is running!
📝 API: http://localhost:${port}/api
📚 Swagger Docs: http://localhost:${port}/api/docs
🌍 Environment: ${process.env.NODE_ENV || 'development'}
  `);
}

bootstrap();
