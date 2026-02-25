import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsUUID, IsNumber, IsString, IsIn, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class FilterProductsDto {
    @ApiPropertyOptional({ example: 1, description: 'Page number', default: 1 })
    @IsOptional()
    @IsNumber()
    @Min(1)
    @Type(() => Number)
    page?: number = 1;

    @ApiPropertyOptional({ example: 20, description: 'Items per page', default: 20 })
    @IsOptional()
    @IsNumber()
    @Min(1)
    @Type(() => Number)
    limit?: number = 20;

    @ApiPropertyOptional({ description: 'Filter by category UUID' })
    @IsOptional()
    @IsUUID()
    categoryId?: string;

    @ApiPropertyOptional({ description: 'Filter by seller UUID' })
    @IsOptional()
    @IsUUID()
    sellerId?: string;

    @ApiPropertyOptional({ example: 10, description: 'Minimum price' })
    @IsOptional()
    @IsNumber()
    @Min(0)
    @Type(() => Number)
    minPrice?: number;

    @ApiPropertyOptional({ example: 1000, description: 'Maximum price' })
    @IsOptional()
    @IsNumber()
    @Min(0)
    @Type(() => Number)
    maxPrice?: number;

    @ApiPropertyOptional({ example: 'iphone', description: 'Search query' })
    @IsOptional()
    @IsString()
    search?: string;

    @ApiPropertyOptional({
        example: 'createdAt',
        description: 'Sort by field',
        enum: ['createdAt', 'price', 'rating', 'viewsCount', 'ordersCount']
    })
    @IsOptional()
    @IsIn(['createdAt', 'price', 'rating', 'viewsCount', 'ordersCount'])
    sortBy?: string = 'createdAt';

    @ApiPropertyOptional({
        example: 'DESC',
        description: 'Sort order',
        enum: ['ASC', 'DESC']
    })
    @IsOptional()
    @IsIn(['ASC', 'DESC'])
    sortOrder?: 'ASC' | 'DESC' = 'DESC';
}
