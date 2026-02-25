import {
    Entity,
    PrimaryGeneratedColumn,
    Column,
    CreateDateColumn,
    UpdateDateColumn,
    ManyToOne,
    JoinColumn,
} from 'typeorm';
import { Order } from '../../orders/entities/order.entity';

export enum PaymentProvider {
    PAYME = 'payme',
    CLICK = 'click',
    CASH = 'cash',
}

export enum TransactionStatus {
    PENDING = 'pending',
    PROCESSING = 'processing',
    PAID = 'paid',
    CANCELLED = 'cancelled',
    FAILED = 'failed',
}

@Entity('transactions')
export class Transaction {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column('uuid')
    orderId: string;

    @ManyToOne(() => Order)
    @JoinColumn({ name: 'orderId' })
    order: Order;

    @Column({
        type: 'enum',
        enum: PaymentProvider,
    })
    provider: PaymentProvider;

    @Column({ unique: true })
    transactionId: string;

    @Column({ type: 'decimal', precision: 12, scale: 2 })
    amount: number;

    @Column({
        type: 'enum',
        enum: TransactionStatus,
        default: TransactionStatus.PENDING,
    })
    status: TransactionStatus;

    @Column({ type: 'jsonb', nullable: true })
    providerData: any;

    @Column({ type: 'jsonb', nullable: true })
    metadata: any;

    @Column({ nullable: true })
    errorMessage: string;

    @Column({ nullable: true })
    paidAt: Date;

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}
