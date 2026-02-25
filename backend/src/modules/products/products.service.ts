import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, ILike } from 'typeorm';
import { Product } from './entities/product.entity';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { FilterProductsDto } from './dto/filter-products.dto';

@Injectable()
export class ProductsService {
    constructor(
        @InjectRepository(Product)
        private productsRepository: Repository<Product>,
    ) { }

    async create(sellerId: string, createProductDto: CreateProductDto): Promise<Product> {
        const product = this.productsRepository.create({
            ...createProductDto,
            sellerId,
        });

        return this.productsRepository.save(product);
    }

    async findAll(filters: FilterProductsDto) {
        const {
            page = 1,
            limit = 20,
            categoryId,
            sellerId,
            minPrice,
            maxPrice,
            search,
            sortBy = 'createdAt',
            sortOrder = 'DESC',
        } = filters;

        const query = this.productsRepository.createQueryBuilder('product')
            .leftJoinAndSelect('product.category', 'category')
            .leftJoinAndSelect('product.seller', 'seller')
            .where('product.isActive = :isActive', { isActive: true });

        // Filters
        if (categoryId) {
            query.andWhere('product.categoryId = :categoryId', { categoryId });
        }

        if (sellerId) {
            query.andWhere('product.sellerId = :sellerId', { sellerId });
        }

        if (minPrice) {
            query.andWhere('product.price >= :minPrice', { minPrice });
        }

        if (maxPrice) {
            query.andWhere('product.price <= :maxPrice', { maxPrice });
        }

        if (search) {
            query.andWhere(
                '(product.name ILIKE :search OR product.description ILIKE :search)',
                { search: `%${search}%` },
            );
        }

        // Sorting
        query.orderBy(`product.${sortBy}`, sortOrder as 'ASC' | 'DESC');

        // Pagination
        const skip = (page - 1) * limit;
        query.skip(skip).take(limit);

        const [products, total] = await query.getManyAndCount();

        return {
            data: products,
            meta: {
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit),
            },
        };
    }

    async findOne(id: string): Promise<Product> {
        const product = await this.productsRepository.findOne({
            where: { id },
            relations: ['category', 'seller'],
        });

        if (!product) {
            throw new NotFoundException('Product not found');
        }

        // Increment views
        await this.productsRepository.increment({ id }, 'viewsCount', 1);

        return product;
    }

    async update(
        id: string,
        sellerId: string,
        updateProductDto: Partial<UpdateProductDto>,
    ): Promise<Product> {
        const product = await this.findOne(id);

        if (product.sellerId !== sellerId) {
            throw new ForbiddenException('You can only update your own products');
        }

        await this.productsRepository.update(id, updateProductDto);
        return this.findOne(id);
    }

    async remove(id: string, sellerId: string): Promise<void> {
        const product = await this.findOne(id);

        if (product.sellerId !== sellerId) {
            throw new ForbiddenException('You can only delete your own products');
        }

        await this.productsRepository.delete(id);
    }

    async toggleActive(id: string, sellerId: string): Promise<Product> {
        const product = await this.findOne(id);

        if (product.sellerId !== sellerId) {
            throw new ForbiddenException('You can only toggle your own products');
        }

        await this.productsRepository.update(id, {
            isActive: !product.isActive,
        });

        return this.findOne(id);
    }

    async getSellerProducts(sellerId: string, filters: FilterProductsDto) {
        return this.findAll({ ...filters, sellerId });
    }
}
