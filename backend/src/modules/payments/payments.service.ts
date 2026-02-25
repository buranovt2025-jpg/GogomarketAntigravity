import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Transaction, PaymentProvider, TransactionStatus } from './entities/transaction.entity';
import { OrdersService } from '../orders/orders.service';
import { PaymentStatus } from '../orders/entities/order.entity';
import { PaymeService } from './services/payme.service';
import { ClickService } from './services/click.service';

@Injectable()
export class PaymentsService {
    constructor(
        @InjectRepository(Transaction)
        private transactionsRepository: Repository<Transaction>,
        private ordersService: OrdersService,
        private paymeService: PaymeService,
        private clickService: ClickService,
    ) { }

    /**
     * Create payment link for order
     */
    async createPaymentLink(
        orderId: string,
        provider: PaymentProvider,
        returnUrl: string,
    ): Promise<string> {
        const order = await this.ordersService.findOne(orderId);

        if (!order) {
            throw new NotFoundException('Order not found');
        }

        const amount = Number(order.total);

        let paymentLink: string;

        switch (provider) {
            case PaymentProvider.PAYME:
                paymentLink = this.paymeService.generatePaymentLink(orderId, amount, returnUrl);
                break;

            case PaymentProvider.CLICK:
                paymentLink = this.clickService.generatePaymentLink(orderId, amount, returnUrl);
                break;

            default:
                throw new Error(`Unsupported payment provider: ${provider}`);
        }

        return paymentLink;
    }

    /**
     * Create transaction record
     */
    async createTransaction(
        orderId: string,
        provider: PaymentProvider,
        transactionId: string,
        amount: number,
        providerData?: any,
    ): Promise<Transaction> {
        const transaction = this.transactionsRepository.create({
            orderId,
            provider,
            transactionId,
            amount,
            status: TransactionStatus.PENDING,
            providerData,
        });

        return this.transactionsRepository.save(transaction);
    }

    /**
     * Update transaction status
     */
    async updateTransactionStatus(
        transactionId: string,
        status: TransactionStatus,
        errorMessage?: string,
    ): Promise<Transaction> {
        const transaction = await this.transactionsRepository.findOne({
            where: { transactionId },
        });

        if (!transaction) {
            throw new NotFoundException('Transaction not found');
        }

        transaction.status = status;

        if (status === TransactionStatus.PAID) {
            transaction.paidAt = new Date();
            // Update order payment status
            await this.ordersService.updatePaymentStatus(transaction.orderId, PaymentStatus.PAID);
        }

        if (status === TransactionStatus.FAILED || status === TransactionStatus.CANCELLED) {
            transaction.errorMessage = errorMessage;
            await this.ordersService.updatePaymentStatus(transaction.orderId, PaymentStatus.FAILED);
        }

        return this.transactionsRepository.save(transaction);
    }

    /**
     * Get transaction by ID
     */
    async getTransaction(transactionId: string): Promise<Transaction> {
        const transaction = await this.transactionsRepository.findOne({
            where: { transactionId },
            relations: ['order'],
        });

        if (!transaction) {
            throw new NotFoundException('Transaction not found');
        }

        return transaction;
    }

    /**
     * Get all transactions for order
     */
    async getOrderTransactions(orderId: string): Promise<Transaction[]> {
        return this.transactionsRepository.find({
            where: { orderId },
            order: { createdAt: 'DESC' },
        });
    }
}
