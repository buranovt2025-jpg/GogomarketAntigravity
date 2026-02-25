import {
    WebSocketGateway,
    WebSocketServer,
    SubscribeMessage,
    OnGatewayConnection,
    OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger } from '@nestjs/common';

@WebSocketGateway({
    cors: {
        origin: '*',
    },
})
export class NotificationsGateway
    implements OnGatewayConnection, OnGatewayDisconnect {
    @WebSocketServer()
    server: Server;

    private logger: Logger = new Logger('NotificationsGateway');
    private userSockets: Map<string, string> = new Map(); // userId -> socketId

    handleConnection(client: Socket) {
        this.logger.log(`Client connected: ${client.id}`);
    }

    handleDisconnect(client: Socket) {
        this.logger.log(`Client disconnected: ${client.id}`);

        // Remove from user sockets map
        for (const [userId, socketId] of this.userSockets.entries()) {
            if (socketId === client.id) {
                this.userSockets.delete(userId);
                break;
            }
        }
    }

    @SubscribeMessage('register')
    handleRegister(client: Socket, userId: string) {
        this.userSockets.set(userId, client.id);
        this.logger.log(`User ${userId} registered with socket ${client.id}`);
        return { status: 'registered' };
    }

    // Send notification to specific user
    sendToUser(userId: string, event: string, data: any) {
        const socketId = this.userSockets.get(userId);
        if (socketId) {
            this.server.to(socketId).emit(event, data);
        }
    }

    // Broadcast to all connected clients
    broadcast(event: string, data: any) {
        this.server.emit(event, data);
    }

    // Send notification about new order
    sendNewOrderNotification(sellerId: string, orderId: string) {
        this.sendToUser(sellerId, 'new-order', {
            orderId,
            message: 'You have a new order!',
            timestamp: new Date().toISOString(),
        });
    }

    // Send notification about order status change
    sendOrderStatusUpdate(userId: string, orderId: string, status: string) {
        this.sendToUser(userId, 'order-status', {
            orderId,
            status,
            timestamp: new Date().toISOString(),
        });
    }

    // Send notification about new comment on story
    sendNewCommentNotification(sellerId: string, storyId: string, commentId: string) {
        this.sendToUser(sellerId, 'new-comment', {
            storyId,
            commentId,
            message: 'Someone commented on your story!',
            timestamp: new Date().toISOString(),
        });
    }

    // Send notification about new like
    sendNewLikeNotification(sellerId: string, storyId: string) {
        this.sendToUser(sellerId, 'new-like', {
            storyId,
            message: 'Someone liked your story!',
            timestamp: new Date().toISOString(),
        });
    }
}
