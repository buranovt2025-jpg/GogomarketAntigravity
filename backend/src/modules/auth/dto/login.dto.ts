import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsPhoneNumber, IsString } from 'class-validator';

export class LoginDto {
    @ApiProperty({ example: '+998901234567', description: 'Phone number' })
    @IsNotEmpty()
    @IsPhoneNumber('UZ')
    phone: string;

    @ApiProperty({ example: 'Password123!', description: 'Password' })
    @IsNotEmpty()
    @IsString()
    password: string;
}
