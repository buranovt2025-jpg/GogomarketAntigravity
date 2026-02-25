import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ChatGateway } from './chat.gateway';
import { ChatService } from './chat.service';
import { ChatController } from './chat.controller';
import { Message } from './entities/message.entity';

@Module({
    imports: [TypeOrmModule.forFeature([Message])],
    controllers: [ChatController],
    providers: [ChatGateway, ChatService],
    exports: [ChatService],
})
export class ChatModule { }
