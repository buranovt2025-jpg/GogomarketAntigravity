import { Controller, Get, Put, Body, UseGuards, Request, Param } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('users')
@Controller('users')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class UsersController {
    constructor(private usersService: UsersService) { }

    @Get('profile')
    @ApiOperation({ summary: 'Get current user profile' })
    @ApiResponse({ status: 200, description: 'User profile retrieved' })
    async getProfile(@Request() req) {
        const user = await this.usersService.findById(req.user.id);
        const { passwordHash, ...sanitized } = user;
        return sanitized;
    }

    @Get('sellers/:id')
    @ApiOperation({ summary: 'Get seller public profile' })
    @ApiResponse({ status: 200, description: 'Seller profile retrieved' })
    async getSellerProfile(@Param('id') sellerId: string) {
        const seller = await this.usersService.findById(sellerId);

        if (!seller || !seller.sellerProfile) {
            return null;
        }

        const { passwordHash, ...sanitizedUser } = seller;
        return {
            ...sanitizedUser,
            sellerProfile: seller.sellerProfile,
        };
    }
}
