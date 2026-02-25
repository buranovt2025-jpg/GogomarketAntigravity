import {
    Controller,
    Get,
    Post,
    Delete,
    Body,
    Param,
    Query,
    UseGuards,
    Request,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { CommentsService } from './comments.service';
import { CreateCommentDto } from './dto/create-comment.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('comments')
@Controller('comments')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class CommentsController {
    constructor(private commentsService: CommentsService) { }

    @Post()
    @ApiOperation({ summary: 'Create a comment' })
    @ApiResponse({ status: 201, description: 'Comment created' })
    async create(@Request() req, @Body() createCommentDto: CreateCommentDto) {
        return this.commentsService.create(req.user.userId, createCommentDto);
    }

    @Get('story/:storyId')
    @ApiOperation({ summary: 'Get comments for a story' })
    @ApiResponse({ status: 200, description: 'Comments retrieved' })
    async getByStory(
        @Param('storyId') storyId: string,
        @Query('limit') limit?: number,
        @Query('offset') offset?: number,
    ) {
        return this.commentsService.getByStory(storyId, limit, offset);
    }

    @Get('story/:storyId/count')
    @ApiOperation({ summary: 'Get comments count' })
    @ApiResponse({ status: 200, description: 'Count retrieved' })
    async getCount(@Param('storyId') storyId: string) {
        const count = await this.commentsService.getCount(storyId);
        return { count };
    }

    @Get(':id/replies')
    @ApiOperation({ summary: 'Get replies to a comment' })
    @ApiResponse({ status: 200, description: 'Replies retrieved' })
    async getReplies(@Param('id') id: string) {
        return this.commentsService.getReplies(id);
    }

    @Delete(':id')
    @ApiOperation({ summary: 'Delete comment' })
    @ApiResponse({ status: 200, description: 'Comment deleted' })
    async delete(@Param('id') id: string, @Request() req) {
        await this.commentsService.delete(id, req.user.userId);
        return { success: true };
    }
}
