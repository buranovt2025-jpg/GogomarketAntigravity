import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsArray, IsEnum, IsString, IsNumber, IsOptional, ValidateNested, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { PaymentMethod } from '../entities/order.entity';

class OrderItemDto {
    @ApiProperty({ description: 'Product UUID' })
    @IsNotEmpty()
    @IsString()
    productId: string;

    @ApiProperty({ example: 2, description: 'Quantity' })
    @IsNotEmpty()
    @IsNumber()
    @Min(1)
    quantity: number;
}

class DeliveryAddressDto {
    @ApiProperty({ example: 'John Doe' })
    @IsNotEmpty()
    @IsString()
    name: string;

    @ApiProperty({ example: '+998901234567' })
    @IsNotEmpty()
    @IsString()
    phone: string;

    @ApiProperty({ example: '123 Main St, Apt 4B' })
    @IsNotEmpty()
    @IsString()
    address: string;

    @ApiProperty({ example: 'Tashkent' })
    @IsNotEmpty()
    @IsString()
    city: string;

    @ApiPropertyOptional({ example: 41.2995 })
    @IsOptional()
    @IsNumber()
    latitude?: number;

    @ApiPropertyOptional({ example: 69.2401 })
    @IsOptional()
    @IsNumber()
    longitude?: number;
}

export class CreateOrderDto {
    @ApiProperty({ type: [OrderItemDto], description: 'Order items' })
    @IsNotEmpty()
    @IsArray()
    @ValidateNested({ each: true })
    @Type(() => OrderItemDto)
    items: OrderItemDto[];

    @ApiProperty({ enum: PaymentMethod, example: PaymentMethod.PAYME })
    @IsNotEmpty()
    @IsEnum(PaymentMethod)
    paymentMethod: PaymentMethod;

    @ApiProperty({ type: DeliveryAddressDto })
    @IsNotEmpty()
    @ValidateNested()
    @Type(() => DeliveryAddressDto)
    deliveryAddress: DeliveryAddressDto;

    @ApiPropertyOptional({ example: 10000, description: 'Delivery fee in UZS' })
    @IsOptional()
    @IsNumber()
    @Min(0)
    deliveryFee?: number;

    @ApiPropertyOptional({ example: 'Please call before delivery' })
    @IsOptional()
    @IsString()
    notes?: string;
}
