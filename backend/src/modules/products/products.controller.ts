import {
    Controller,
    Get,
    Post,
    Put,
    Delete,
    Body,
    Param,
    Query,
    UseGuards,
    Request,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { ProductsService } from './products.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { FilterProductsDto } from './dto/filter-products.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';

@ApiTags('products')
@Controller('products')
export class ProductsController {
    constructor(private productsService: ProductsService) { }

    @Get()
    @ApiOperation({ summary: 'Get all products with filters' })
    @ApiResponse({ status: 200, description: 'Products retrieved successfully' })
    async findAll(@Query() filters: FilterProductsDto) {
        return this.productsService.findAll(filters);
    }

    @Get('search')
    @ApiOperation({ summary: 'Search products' })
    @ApiQuery({ name: 'q', required: true, description: 'Search query' })
    async search(@Query('q') query: string, @Query() filters: FilterProductsDto) {
        return this.productsService.findAll({ ...filters, search: query });
    }

    @Get(':id')
    @ApiOperation({ summary: 'Get product by ID' })
    @ApiResponse({ status: 200, description: 'Product retrieved successfully' })
    @ApiResponse({ status: 404, description: 'Product not found' })
    async findOne(@Param('id') id: string) {
        return this.productsService.findOne(id);
    }

    @Post()
    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(UserRole.SELLER)
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Create new product (sellers only)' })
    @ApiResponse({ status: 201, description: 'Product created successfully' })
    @ApiResponse({ status: 403, description: 'Forbidden - sellers only' })
    async create(@Request() req, @Body() createProductDto: CreateProductDto) {
        return this.productsService.create(req.user.sellerProfile.id, createProductDto);
    }

    @Put(':id')
    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(UserRole.SELLER)
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Update product (owner only)' })
    @ApiResponse({ status: 200, description: 'Product updated successfully' })
    @ApiResponse({ status: 403, description: 'Forbidden - not the owner' })
    @ApiResponse({ status: 404, description: 'Product not found' })
    async update(
        @Param('id') id: string,
        @Request() req,
        @Body() updateProductDto: UpdateProductDto,
    ) {
        return this.productsService.update(id, req.user.sellerProfile.id, updateProductDto);
    }

    @Delete(':id')
    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(UserRole.SELLER)
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Delete product (owner only)' })
    @ApiResponse({ status: 200, description: 'Product deleted successfully' })
    @ApiResponse({ status: 403, description: 'Forbidden - not the owner' })
    @ApiResponse({ status: 404, description: 'Product not found' })
    async remove(@Param('id') id: string, @Request() req) {
        await this.productsService.remove(id, req.user.sellerProfile.id);
        return { message: 'Product deleted successfully' };
    }

    @Put(':id/toggle')
    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(UserRole.SELLER)
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Toggle product active status (owner only)' })
    @ApiResponse({ status: 200, description: 'Product status toggled' })
    async toggleActive(@Param('id') id: string, @Request() req) {
        return this.productsService.toggleActive(id, req.user.sellerProfile.id);
    }

    @Get('seller/my-products')
    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(UserRole.SELLER)
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Get my products (seller)' })
    @ApiResponse({ status: 200, description: 'Seller products retrieved' })
    async getMyProducts(@Request() req, @Query() filters: FilterProductsDto) {
        return this.productsService.getSellerProducts(req.user.sellerProfile.id, filters);
    }
}
