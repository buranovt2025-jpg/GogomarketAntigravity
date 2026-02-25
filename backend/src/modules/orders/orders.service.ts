import { Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Order, OrderStatus, PaymentStatus, OrderItem } from './entities/order.entity';
import { CreateOrderDto } from './dto/create-order.dto';
import { UpdateOrderStatusDto } from './dto/update-order-status.dto';
import { ProductsService } from '../products/products.service';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class OrdersService {
    constructor(
        @InjectRepository(Order)
        private ordersRepository: Repository<Order>,
        @InjectRepository(OrderItem)
        private orderItemsRepository: Repository<OrderItem>,
        private productsService: ProductsService,
        private configService: ConfigService,
    ) { }

    async create(buyerId: string, createOrderDto: CreateOrderDto): Promise<Order> {
        // Calculate totals
        let subtotal = 0;
        const items = [];

        for (const item of createOrderDto.items) {
            const product = await this.productsService.findOne(item.productId);

            if (!product) {
                throw new NotFoundException(`Product ${item.productId} not found`);
            }

            if (product.stockQuantity < item.quantity) {
                throw new BadRequestException(
                    `Insufficient stock for ${product.name}. Available: ${product.stockQuantity}`,
                );
            }

            const itemSubtotal = Number(product.price) * item.quantity;
            subtotal += itemSubtotal;

            items.push({
                productId: product.id,
                productName: product.name,
                price: product.price,
                quantity: item.quantity,
                subtotal: itemSubtotal,
                productSnapshot: {
                    name: product.name,
                    price: product.price,
                    images: product.images,
                },
            });
        }

        const deliveryFee = createOrderDto.deliveryFee || 0;
        const platformCommissionRate = Number(
            this.configService.get('PLATFORM_COMMISSION_RATE', 0.1),
        );
        const platformFee = subtotal * platformCommissionRate;
        const total = subtotal + deliveryFee;

        // Generate order number
        const orderNumber = this.generateOrderNumber();

        // Get seller ID from first product
        const firstProduct = await this.productsService.findOne(createOrderDto.items[0].productId);
        const sellerId = firstProduct.sellerId;

        // Create order
        const order = this.ordersRepository.create({
            orderNumber,
            buyerId,
            sellerId,
            paymentMethod: createOrderDto.paymentMethod,
            subtotal,
            deliveryFee,
            platformFee,
            total,
            deliveryAddress: createOrderDto.deliveryAddress,
            notes: createOrderDto.notes,
        });

        const savedOrder = await this.ordersRepository.save(order);

        // Create order items
        for (const item of items) {
            const orderItem = this.orderItemsRepository.create({
                ...item,
                orderId: savedOrder.id,
            });
            await this.orderItemsRepository.save(orderItem);
        }

        // Update product stock
        for (const item of createOrderDto.items) {
            const product = await this.productsService.findOne(item.productId);
            product.stockQuantity -= item.quantity;
            product.ordersCount += 1;
            await this.productsService.update(item.productId, sellerId, {
                stockQuantity: product.stockQuantity,
            });
        }

        return this.findOne(savedOrder.id);
    }

    async findAll(userId: string, role: string, filters?: any) {
        const query = this.ordersRepository
            .createQueryBuilder('order')
            .leftJoinAndSelect('order.items', 'items')
            .leftJoinAndSelect('order.buyer', 'buyer')
            .leftJoinAndSelect('order.seller', 'seller');

        if (role === 'buyer') {
            query.where('order.buyerId = :userId', { userId });
        } else if (role === 'seller') {
            query.where('order.sellerId = :userId', { userId });
        } else if (role === 'courier') {
            query.where('order.courierId = :userId OR order.status = :status', {
                userId,
                status: OrderStatus.CONFIRMED,
            });
        }

        if (filters?.status) {
            query.andWhere('order.status = :status', { status: filters.status });
        }

        query.orderBy('order.createdAt', 'DESC');

        return query.getMany();
    }

    async findOne(id: string): Promise<Order> {
        const order = await this.ordersRepository.findOne({
            where: { id },
            relations: ['items', 'buyer', 'seller'],
        });

        if (!order) {
            throw new NotFoundException('Order not found');
        }

        return order;
    }

    async updateStatus(
        id: string,
        userId: string,
        role: string,
        updateDto: UpdateOrderStatusDto,
    ): Promise<Order> {
        const order = await this.findOne(id);

        // Authorization check
        if (role === 'seller' && order.sellerId !== userId) {
            throw new ForbiddenException('You can only update your own orders');
        }

        if (role === 'buyer' && order.buyerId !== userId) {
            throw new ForbiddenException('You can only update your own orders');
        }

        const updateData: Partial<Order> = {
            status: updateDto.status,
        };

        if (updateDto.status === OrderStatus.CANCELLED) {
            updateData.cancelledAt = new Date();
            updateData.cancellationReason = updateDto.cancellationReason;

            // Restore stock
            for (const item of order.items) {
                const product = await this.productsService.findOne(item.productId);
                if (product) {
                    product.stockQuantity += item.quantity;
                    await this.productsService.update(item.productId, order.sellerId, {
                        stockQuantity: product.stockQuantity,
                    });
                }
            }
        }

        if (updateDto.status === OrderStatus.DELIVERED) {
            updateData.deliveredAt = new Date();
        }

        await this.ordersRepository.update(id, updateData);
        return this.findOne(id);
    }

    async assignCourier(orderId: string, courierId: string): Promise<Order> {
        const order = await this.findOne(orderId);

        if (order.status !== OrderStatus.CONFIRMED) {
            throw new BadRequestException('Only confirmed orders can be assigned to courier');
        }

        await this.ordersRepository.update(orderId, {
            courierId,
            status: OrderStatus.PROCESSING,
        });

        return this.findOne(orderId);
    }

    async updatePaymentStatus(orderId: string, status: PaymentStatus): Promise<Order> {
        await this.ordersRepository.update(orderId, { paymentStatus: status });

        if (status === PaymentStatus.PAID) {
            await this.ordersRepository.update(orderId, { status: OrderStatus.CONFIRMED });
        }

        return this.findOne(orderId);
    }

    private generateOrderNumber(): string {
        const timestamp = Date.now().toString(36).toUpperCase();
        const random = Math.random().toString(36).substring(2, 6).toUpperCase();
        return `ORD-${timestamp}-${random}`;
    }

    async getStats(sellerId: string) {
        const orders = await this.ordersRepository.find({
            where: { sellerId },
        });

        const totalOrders = orders.length;
        const totalRevenue = orders.reduce((sum, order) => sum + Number(order.subtotal), 0);
        const pendingOrders = orders.filter((o) => o.status === OrderStatus.PENDING).length;
        const completedOrders = orders.filter((o) => o.status === OrderStatus.DELIVERED).length;

        return {
            totalOrders,
            totalRevenue,
            pendingOrders,
            completedOrders,
        };
    }

    async getPlatformStats() {
        const orders = await this.ordersRepository.find();

        const totalOrders = orders.length;
        const totalRevenue = orders.reduce((sum, order) => sum + Number(order.total), 0);
        const totalCommission = orders.reduce((sum, order) => sum + Number(order.platformFee || 0), 0);

        const activeOrders = orders.filter(o =>
            o.status !== OrderStatus.DELIVERED &&
            o.status !== OrderStatus.CANCELLED
        ).length;

        return {
            totalOrders,
            totalRevenue,
            totalCommission,
            activeOrders,
        };
    }
}
