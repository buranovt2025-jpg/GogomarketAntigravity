import { IsString, IsOptional, IsUUID } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateCommentDto {
    @ApiProperty({ description: 'Story ID' })
    @IsUUID()
    storyId: string;

    @ApiProperty({ description: 'Comment content' })
    @IsString()
    content: string;

    @ApiPropertyOptional({ description: 'Parent comment ID for replies' })
    @IsUUID()
    @IsOptional()
    parentId?: string;
}
