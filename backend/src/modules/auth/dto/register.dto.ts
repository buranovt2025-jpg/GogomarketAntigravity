import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEmail, IsEnum, IsNotEmpty, IsOptional, IsPhoneNumber, IsString, MinLength } from 'class-validator';
import { UserRole } from '../../users/entities/user.entity';
import { CabinetType, SimplifiedCategory } from '../../users/entities/seller-profile.entity';

export class RegisterDto {
    @ApiProperty({ example: '+998901234567', description: 'Phone number' })
    @IsNotEmpty()
    @IsPhoneNumber('UZ')
    phone: string;

    @ApiPropertyOptional({ example: 'user@example.com', description: 'Email address' })
    @IsOptional()
    @IsEmail()
    email?: string;

    @ApiProperty({ example: 'Password123!', description: 'Password (min 6 characters)' })
    @IsNotEmpty()
    @IsString()
    @MinLength(6)
    password: string;

    @ApiProperty({ enum: UserRole, example: UserRole.BUYER, description: 'User role' })
    @IsNotEmpty()
    @IsEnum(UserRole)
    role: UserRole;

    // Seller-specific fields
    @ApiPropertyOptional({ example: 'My Store', description: 'Store name (for sellers)' })
    @IsOptional()
    @IsString()
    storeName?: string;

    @ApiPropertyOptional({ enum: CabinetType, example: CabinetType.FULL, description: 'Cabinet type (for sellers)' })
    @IsOptional()
    @IsEnum(CabinetType)
    cabinetType?: CabinetType;

    @ApiPropertyOptional({ enum: SimplifiedCategory, description: 'Category (for simplified cabinet)' })
    @IsOptional()
    @IsEnum(SimplifiedCategory)
    category?: SimplifiedCategory;

    // Buyer-specific fields
    @ApiPropertyOptional({ example: 'John Doe', description: 'Full name (for buyers)' })
    @IsOptional()
    @IsString()
    name?: string;
}
