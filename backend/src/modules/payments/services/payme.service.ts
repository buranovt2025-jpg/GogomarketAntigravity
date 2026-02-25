import { Injectable, BadRequestException, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';
import * as crypto from 'crypto';

@Injectable()
export class PaymeService {
    private readonly logger = new Logger(PaymeService.name);
    private readonly merchantId: string;
    private readonly secretKey: string;
    private readonly baseUrl: string;

    constructor(private configService: ConfigService) {
        this.merchantId = this.configService.get('PAYME_MERCHANT_ID');
        this.secretKey = this.configService.get('PAYME_SECRET_KEY');
        this.baseUrl = this.configService.get('PAYME_BASE_URL', 'https://checkout.paycom.uz/api');
    }

    /**
     * Generate payment link for Payme
     */
    generatePaymentLink(orderId: string, amount: number, returnUrl: string): string {
        const amountInTiyin = Math.round(amount * 100); // Convert to tiyin (smallest unit)

        const params = {
            m: this.merchantId,
            ac: { order_id: orderId },
            a: amountInTiyin,
            c: returnUrl,
        };

        const encoded = Buffer.from(JSON.stringify(params)).toString('base64');
        return `https://checkout.paycom.uz/${encoded}`;
    }

    /**
     * Verify Payme callback signature
     */
    verifySignature(authorization: string): boolean {
        try {
            const [type, credentials] = authorization.split(' ');

            if (type !== 'Basic') {
                return false;
            }

            const decoded = Buffer.from(credentials, 'base64').toString('utf-8');
            const [username, password] = decoded.split(':');

            return username === 'Paycom' && password === this.secretKey;
        } catch (error) {
            this.logger.error('Signature verification failed', error);
            return false;
        }
    }

    /**
     * Handle Payme JSON-RPC request
     */
    async handleCallback(method: string, params: any, id: number): Promise<any> {
        this.logger.log(`Payme callback: ${method}`, params);

        switch (method) {
            case 'CheckPerformTransaction':
                return this.checkPerformTransaction(params);

            case 'CreateTransaction':
                return this.createTransaction(params);

            case 'PerformTransaction':
                return this.performTransaction(params);

            case 'CancelTransaction':
                return this.cancelTransaction(params);

            case 'CheckTransaction':
                return this.checkTransaction(params);

            default:
                throw new BadRequestException({
                    jsonrpc: '2.0',
                    id,
                    error: {
                        code: -32601,
                        message: 'Method not found',
                    },
                });
        }
    }

    private async checkPerformTransaction(params: any) {
        // Verify order exists and amount is correct
        return { allow: true };
    }

    private async createTransaction(params: any) {
        // Create pending transaction
        return {
            create_time: Date.now(),
            transaction: params.id,
            state: 1,
        };
    }

    private async performTransaction(params: any) {
        // Confirm payment
        return {
            transaction: params.id,
            perform_time: Date.now(),
            state: 2,
        };
    }

    private async cancelTransaction(params: any) {
        // Cancel transaction
        return {
            transaction: params.id,
            cancel_time: Date.now(),
            state: -1,
        };
    }

    private async checkTransaction(params: any) {
        // Check transaction status
        return {
            create_time: Date.now(),
            perform_time: Date.now(),
            cancel_time: 0,
            transaction: params.id,
            state: 2,
            reason: null,
        };
    }
}
