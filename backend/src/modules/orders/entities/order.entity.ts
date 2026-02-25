import {
    Entity,
    PrimaryGeneratedColumn,
    Column,
    CreateDateColumn,
    UpdateDateColumn,
    ManyToOne,
    OneToMany,
    JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { SellerProfile } from '../../users/entities/seller-profile.entity';

export enum OrderStatus {
    PENDING = 'pending',
    CONFIRMED = 'confirmed',
    PROCESSING = 'processing',
    SHIPPED = 'shipped',
    DELIVERED = 'delivered',
    CANCELLED = 'cancelled',
    REFUNDED = 'refunded',
}

export enum PaymentStatus {
    PENDING = 'pending',
    PAID = 'paid',
    FAILED = 'failed',
    REFUNDED = 'refunded',
}

export enum PaymentMethod {
    PAYME = 'payme',
    CLICK = 'click',
    CASH = 'cash',
}

@Entity('orders')
export class Order {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column({ unique: true })
    orderNumber: string;

    @Column('uuid')
    buyerId: string;

    @ManyToOne(() => User)
    @JoinColumn({ name: 'buyerId' })
    buyer: User;

    @Column('uuid')
    sellerId: string;

    @ManyToOne(() => SellerProfile)
    @JoinColumn({ name: 'sellerId' })
    seller: SellerProfile;

    @OneToMany(() => OrderItem, (item) => item.order, { cascade: true })
    items: OrderItem[];

    @Column({
        type: 'enum',
        enum: OrderStatus,
        default: OrderStatus.PENDING,
    })
    status: OrderStatus;

    @Column({
        type: 'enum',
        enum: PaymentStatus,
        default: PaymentStatus.PENDING,
    })
    paymentStatus: PaymentStatus;

    @Column({
        type: 'enum',
        enum: PaymentMethod,
    })
    paymentMethod: PaymentMethod;

    @Column({ type: 'decimal', precision: 12, scale: 2 })
    subtotal: number;

    @Column({ type: 'decimal', precision: 12, scale: 2, default: 0 })
    deliveryFee: number;

    @Column({ type: 'decimal', precision: 12, scale: 2, default: 0 })
    platformFee: number;

    @Column({ type: 'decimal', precision: 12, scale: 2 })
    total: number;

    @Column({ type: 'jsonb' })
    deliveryAddress: {
        name: string;
        phone: string;
        address: string;
        city: string;
        latitude?: number;
        longitude?: number;
    };

    @Column({ type: 'text', nullable: true })
    notes: string;

    @Column({ nullable: true })
    courierId: string;

    @Column({ nullable: true })
    estimatedDeliveryTime: Date;

    @Column({ nullable: true })
    deliveredAt: Date;

    @Column({ nullable: true })
    cancelledAt: Date;

    @Column({ type: 'text', nullable: true })
    cancellationReason: string;

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}

@Entity('order_items')
export class OrderItem {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column('uuid')
    orderId: string;

    @ManyToOne(() => Order, (order) => order.items, { onDelete: 'CASCADE' })
    @JoinColumn({ name: 'orderId' })
    order: Order;

    @Column('uuid')
    productId: string;

    @Column()
    productName: string;

    @Column({ type: 'decimal', precision: 12, scale: 2 })
    price: number;

    @Column()
    quantity: number;

    @Column({ type: 'decimal', precision: 12, scale: 2 })
    subtotal: number;

    @Column({ type: 'jsonb', nullable: true })
    productSnapshot: any;

    @CreateDateColumn()
    createdAt: Date;
}
