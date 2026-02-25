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
import { StoriesService } from './stories.service';
import { CreateStoryDto } from './dto/create-story.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';

@ApiTags('stories')
@Controller('stories')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class StoriesController {
    constructor(private storiesService: StoriesService) { }

    @Post()
    @UseGuards(RolesGuard)
    @Roles(UserRole.SELLER)
    @ApiOperation({ summary: 'Create a new story (sellers only)' })
    @ApiResponse({ status: 201, description: 'Story created' })
    async create(@Request() req, @Body() createStoryDto: CreateStoryDto) {
        return this.storiesService.create(req.user.userId, createStoryDto);
    }

    @Get('feed')
    @ApiOperation({ summary: 'Get personalized feed' })
    @ApiResponse({ status: 200, description: 'Feed retrieved' })
    async getFeed(
        @Request() req,
        @Query('limit') limit?: number,
        @Query('offset') offset?: number,
    ) {
        return this.storiesService.getFeed(req.user.userId, limit, offset);
    }

    @Get('seller/:sellerId')
    @ApiOperation({ summary: 'Get stories by seller' })
    @ApiResponse({ status: 200, description: 'Stories retrieved' })
    async getBySeller(@Param('sellerId') sellerId: string) {
        return this.storiesService.getBySeller(sellerId);
    }

    @Get('my-stories')
    @UseGuards(RolesGuard)
    @Roles(UserRole.SELLER)
    @ApiOperation({ summary: 'Get my stories' })
    @ApiResponse({ status: 200, description: 'Stories retrieved' })
    async getMyStories(@Request() req) {
        return this.storiesService.getBySeller(req.user.userId);
    }

    @Get('stats')
    @UseGuards(RolesGuard)
    @Roles(UserRole.SELLER)
    @ApiOperation({ summary: 'Get my stories statistics' })
    @ApiResponse({ status: 200, description: 'Stats retrieved' })
    async getStats(@Request() req) {
        return this.storiesService.getStats(req.user.userId);
    }

    @Get(':id')
    @ApiOperation({ summary: 'Get single story' })
    @ApiResponse({ status: 200, description: 'Story retrieved' })
    async getOne(@Param('id') id: string, @Request() req) {
        const story = await this.storiesService.findOne(id);
        const isLiked = await this.storiesService.isLikedByUser(id, req.user.userId);
        return { ...story, isLiked };
    }

    @Post(':id/view')
    @ApiOperation({ summary: 'Record view' })
    @ApiResponse({ status: 200, description: 'View recorded' })
    async recordView(
        @Param('id') id: string,
        @Request() req,
        @Body('watchDuration') watchDuration: number,
    ) {
        await this.storiesService.recordView(id, req.user.userId, watchDuration);
        return { success: true };
    }

    @Post(':id/like')
    @ApiOperation({ summary: 'Toggle like on story' })
    @ApiResponse({ status: 200, description: 'Like toggled' })
    async toggleLike(@Param('id') id: string, @Request() req) {
        return this.storiesService.toggleLike(id, req.user.userId);
    }

    @Delete(':id')
    @UseGuards(RolesGuard)
    @Roles(UserRole.SELLER)
    @ApiOperation({ summary: 'Delete story' })
    @ApiResponse({ status: 200, description: 'Story deleted' })
    async delete(@Param('id') id: string, @Request() req) {
        await this.storiesService.delete(id, req.user.userId);
        return { success: true };
    }
}
