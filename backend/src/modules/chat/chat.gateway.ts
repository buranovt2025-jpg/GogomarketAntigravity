import {
    WebSocketGateway,
    WebSocketServer,
    SubscribeMessage,
    OnGatewayConnection,
    OnGatewayDisconnect,
    MessageBody,
    ConnectedSocket,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger, UseGuards } from '@nestjs/common';
import { ChatService } from './chat.service';

@WebSocketGateway({
    cors: {
        origin: '*',
    },
    namespace: 'chat',
})
export class ChatGateway implements OnGatewayConnection, OnGatewayDisconnect {
    @WebSocketServer()
    server: Server;

    private logger: Logger = new Logger('ChatGateway');
    private activeUsers: Map<string, string> = new Map(); // userId -> socketId

    constructor(private readonly chatService: ChatService) { }

    handleConnection(client: Socket) {
        this.logger.log(`Client connected to chat: ${client.id}`);
    }

    handleDisconnect(client: Socket) {
        this.logger.log(`Client disconnected from chat: ${client.id}`);
        for (const [userId, socketId] of this.activeUsers.entries()) {
            if (socketId === client.id) {
                this.activeUsers.delete(userId);
                break;
            }
        }
    }

    @SubscribeMessage('join')
    handleJoin(
        @ConnectedSocket() client: Socket,
        @MessageBody('userId') userId: string,
    ) {
        this.activeUsers.set(userId, client.id);
        this.logger.log(`User ${userId} joined chat with socket ${client.id}`);
        return { status: 'joined' };
    }

    @SubscribeMessage('send-message')
    async handleMessage(
        @ConnectedSocket() client: Socket,
        @MessageBody() payload: { recipientId: string; senderId: string; content: string },
    ) {
        const { senderId, recipientId, content } = payload;

        // Save to DB
        const message = await this.chatService.saveMessage(senderId, recipientId, content);

        // Send to recipient if online
        const recipientSocketId = this.activeUsers.get(recipientId);
        if (recipientSocketId) {
            this.server.to(recipientSocketId).emit('new-message', message);
        }

        // Send back to sender for confirmation/sync
        client.emit('message-sent', message);

        return message;
    }
}
