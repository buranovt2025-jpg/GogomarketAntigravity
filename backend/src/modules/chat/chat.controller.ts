import { Controller, Get, Param, UseGuards, Req } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ChatService } from './chat.service';

@ApiTags('chat')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('chat')
export class ChatController {
    constructor(private readonly chatService: ChatService) { }

    @Get('history/:otherId')
    @ApiOperation({ summary: 'Get chat history with another user' })
    @ApiResponse({ status: 200, description: 'Return chat history' })
    async getHistory(@Req() req, @Param('otherId') otherId: string) {
        return this.chatService.getChatHistory(req.user.id, otherId);
    }
}
