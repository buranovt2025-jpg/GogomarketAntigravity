import { Controller, Get, Patch, Param, Body, UseGuards, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { UsersService } from '../users/users.service';
import { OrdersService } from '../orders/orders.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';

@ApiTags('admin')
@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN)
@ApiBearerAuth()
export class AdminController {
    constructor(
        private usersService: UsersService,
        private ordersService: OrdersService,
    ) { }

    @Get('stats')
    @ApiOperation({ summary: 'Get platform metrics' })
    @ApiResponse({ status: 200, description: 'Platform stats retrieved' })
    async getStats() {
        const stats = await this.ordersService.getPlatformStats();
        const userCount = await this.usersService.countUsers();
        return {
            ...stats,
            totalUsers: userCount,
        };
    }

    @Get('users')
    @ApiOperation({ summary: 'List all users' })
    async getAllUsers(
        @Query('page') page: number = 1,
        @Query('limit') limit: number = 10,
    ) {
        return this.usersService.findAll(page, limit);
    }

    @Patch('users/:id/role')
    @ApiOperation({ summary: 'Update user role' })
    async updateRole(
        @Param('id') id: string,
        @Body('role') role: UserRole,
    ) {
        return this.usersService.updateRole(id, role);
    }

    @Patch('users/:id/block')
    @ApiOperation({ summary: 'Block/Unblock user' })
    async updateBlockStatus(
        @Param('id') id: string,
        @Body('isBlocked') isBlocked: boolean,
    ) {
        return this.usersService.updateBlockedStatus(id, isBlocked);
    }
}
