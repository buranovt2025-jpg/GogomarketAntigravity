import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Message } from './entities/message.entity';

@Injectable()
export class ChatService {
    constructor(
        @InjectRepository(Message)
        private readonly messageRepository: Repository<Message>,
    ) { }

    async saveMessage(senderId: string, recipientId: string, content: string): Promise<Message> {
        const message = this.messageRepository.create({
            senderId,
            recipientId,
            content,
        });
        return this.messageRepository.save(message);
    }

    async getChatHistory(userId: string, otherId: string): Promise<Message[]> {
        return this.messageRepository.find({
            where: [
                { senderId: userId, recipientId: otherId },
                { senderId: otherId, recipientId: userId },
            ],
            order: { createdAt: 'ASC' },
            relations: ['sender', 'recipient'],
        });
    }

    async markAsRead(messageId: string): Promise<void> {
        await this.messageRepository.update(messageId, { isRead: true });
    }
}
