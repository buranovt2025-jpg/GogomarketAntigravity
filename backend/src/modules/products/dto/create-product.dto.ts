import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsString, IsNumber, IsUUID, IsOptional, Min, IsArray, IsObject } from 'class-validator';
import { Type } from 'class-transformer';

export class CreateProductDto {
    @ApiProperty({ example: 'iPhone 15 Pro', description: 'Product name' })
    @IsNotEmpty()
    @IsString()
    name: string;

    @ApiProperty({ example: 'Latest iPhone with A17 Pro chip', description: 'Product description' })
    @IsNotEmpty()
    @IsString()
    description: string;

    @ApiProperty({ example: 1299.99, description: 'Product price' })
    @IsNotEmpty()
    @IsNumber()
    @Min(0)
    price: number;

    @ApiPropertyOptional({ example: 1499.99, description: 'Old price (for discounts)' })
    @IsOptional()
    @IsNumber()
    @Min(0)
    oldPrice?: number;

    @ApiProperty({ description: 'Category UUID' })
    @IsNotEmpty()
    @IsUUID()
    categoryId: string;

    @ApiPropertyOptional({ example: ['url1.jpg', 'url2.jpg'], description: 'Product images URLs' })
    @IsOptional()
    @IsArray()
    @IsString({ each: true })
    images?: string[];

    @ApiPropertyOptional({ example: 'video.mp4', description: 'Product video URL' })
    @IsOptional()
    @IsString()
    videoUrl?: string;

    @ApiPropertyOptional({
        example: { color: 'Black', size: 'Medium' },
        description: 'Product attributes'
    })
    @IsOptional()
    @IsObject()
    attributes?: Record<string, any>;

    @ApiProperty({ example: 100, description: 'Stock quantity' })
    @IsNotEmpty()
    @IsNumber()
    @Min(0)
    @Type(() => Number)
    stockQuantity: number;
}
