import { IsString, IsOptional, IsInt, Min } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateStoryDto {
    @ApiProperty({ description: 'Video URL' })
    @IsString()
    videoUrl: string;

    @ApiPropertyOptional({ description: 'Thumbnail URL' })
    @IsString()
    @IsOptional()
    thumbnailUrl?: string;

    @ApiPropertyOptional({ description: 'Story description' })
    @IsString()
    @IsOptional()
    description?: string;

    @ApiPropertyOptional({ description: 'Linked product ID' })
    @IsString()
    @IsOptional()
    productId?: string;

    @ApiProperty({ description: 'Video duration in seconds' })
    @IsInt()
    @Min(1)
    duration: number;
}
