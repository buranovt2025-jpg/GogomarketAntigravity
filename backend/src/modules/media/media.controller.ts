import {
    Controller,
    Post,
    Delete,
    UseGuards,
    UseInterceptors,
    UploadedFile,
    Body,
    BadRequestException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiConsumes, ApiBody } from '@nestjs/swagger';
import { MediaService } from './media.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('media')
@Controller('media')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class MediaController {
    constructor(private mediaService: MediaService) { }

    @Post('upload/image')
    @UseInterceptors(FileInterceptor('file'))
    @ApiOperation({ summary: 'Upload image' })
    @ApiConsumes('multipart/form-data')
    @ApiBody({
        schema: {
            type: 'object',
            properties: {
                file: {
                    type: 'string',
                    format: 'binary',
                },
            },
        },
    })
    @ApiResponse({ status: 201, description: 'Image uploaded successfully' })
    @ApiResponse({ status: 400, description: 'Bad request - invalid file type or size' })
    async uploadImage(@UploadedFile() file: Express.Multer.File) {
        if (!file) {
            throw new BadRequestException('No file provided');
        }

        return this.mediaService.uploadImage(file);
    }

    @Post('upload/video')
    @UseInterceptors(FileInterceptor('file'))
    @ApiOperation({ summary: 'Upload video (for Reels/Stories)' })
    @ApiConsumes('multipart/form-data')
    @ApiBody({
        schema: {
            type: 'object',
            properties: {
                file: {
                    type: 'string',
                    format: 'binary',
                },
            },
        },
    })
    @ApiResponse({ status: 201, description: 'Video uploaded successfully' })
    @ApiResponse({ status: 400, description: 'Bad request - invalid file type or size' })
    async uploadVideo(@UploadedFile() file: Express.Multer.File) {
        if (!file) {
            throw new BadRequestException('No file provided');
        }

        return this.mediaService.uploadVideo(file);
    }

    @Delete()
    @ApiOperation({ summary: 'Delete file' })
    @ApiResponse({ status: 200, description: 'File deleted successfully' })
    async deleteFile(@Body('url') url: string) {
        await this.mediaService.deleteFile(url);
        return { message: 'File deleted successfully' };
    }
}
