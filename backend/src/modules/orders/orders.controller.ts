import {
    Controller,
    Get,
    Post,
    Put,
    Body,
    Param,
    Query,
    UseGuards,
    Request,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { OrdersService } from './orders.service';
import { CreateOrderDto } from './dto/create-order.dto';
import { UpdateOrderStatusDto } from './dto/update-order-status.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';

@ApiTags('orders')
@Controller('orders')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class OrdersController {
    constructor(private ordersService: OrdersService) { }

    @Post()
    @UseGuards(RolesGuard)
    @Roles(UserRole.BUYER)
    @ApiOperation({ summary: 'Create new order (buyers only)' })
    @ApiResponse({ status: 201, description: 'Order created successfully' })
    @ApiResponse({ status: 400, description: 'Bad request - insufficient stock' })
    async create(@Request() req, @Body() createOrderDto: CreateOrderDto) {
        return this.ordersService.create(req.user.id, createOrderDto);
    }

    @Get()
    @ApiOperation({ summary: 'Get all orders (filtered by role)' })
    @ApiResponse({ status: 200, description: 'Orders retrieved successfully' })
    async findAll(@Request() req, @Query('status') status?: string) {
        return this.ordersService.findAll(req.user.id, req.user.role, { status });
    }

    @Get('stats')
    @UseGuards(RolesGuard)
    @Roles(UserRole.SELLER)
    @ApiOperation({ summary: 'Get seller order statistics' })
    @ApiResponse({ status: 200, description: 'Statistics retrieved' })
    async getStats(@Request() req) {
        return this.ordersService.getStats(req.user.sellerProfile.id);
    }

    @Get(':id')
    @ApiOperation({ summary: 'Get order by ID' })
    @ApiResponse({ status: 200, description: 'Order retrieved successfully' })
    @ApiResponse({ status: 404, description: 'Order not found' })
    async findOne(@Param('id') id: string) {
        return this.ordersService.findOne(id);
    }

    @Put(':id/status')
    @ApiOperation({ summary: 'Update order status' })
    @ApiResponse({ status: 200, description: 'Order status updated' })
    @ApiResponse({ status: 403, description: 'Forbidden - not your order' })
    async updateStatus(
        @Param('id') id: string,
        @Request() req,
        @Body() updateDto: UpdateOrderStatusDto,
    ) {
        return this.ordersService.updateStatus(id, req.user.id, req.user.role, updateDto);
    }

    @Put(':id/assign-courier')
    @UseGuards(RolesGuard)
    @Roles(UserRole.COURIER, UserRole.ADMIN)
    @ApiOperation({ summary: 'Assign courier to order' })
    @ApiResponse({ status: 200, description: 'Courier assigned' })
    async assignCourier(@Param('id') id: string, @Request() req) {
        return this.ordersService.assignCourier(id, req.user.id);
    }
}
