import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsOptional, IsString } from 'class-validator';
import { OrderStatus } from '../entities/order.entity';

export class UpdateOrderStatusDto {
    @ApiProperty({ enum: OrderStatus, example: OrderStatus.CONFIRMED })
    @IsEnum(OrderStatus)
    status: OrderStatus;

    @ApiPropertyOptional({ example: 'Customer requested cancellation' })
    @IsOptional()
    @IsString()
    cancellationReason?: string;
}
