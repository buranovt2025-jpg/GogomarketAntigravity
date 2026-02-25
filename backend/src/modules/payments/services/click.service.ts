import { Injectable, BadRequestException, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';
import * as crypto from 'crypto';

@Injectable()
export class ClickService {
    private readonly logger = new Logger(ClickService.name);
    private readonly merchantId: string;
    private readonly serviceId: string;
    private readonly secretKey: string;
    private readonly baseUrl: string;

    constructor(private configService: ConfigService) {
        this.merchantId = this.configService.get('CLICK_MERCHANT_ID');
        this.serviceId = this.configService.get('CLICK_SERVICE_ID');
        this.secretKey = this.configService.get('CLICK_SECRET_KEY');
        this.baseUrl = this.configService.get('CLICK_BASE_URL', 'https://my.click.uz/services/pay');
    }

    /**
     * Generate payment link for Click
     */
    generatePaymentLink(orderId: string, amount: number, returnUrl: string): string {
        const params = new URLSearchParams({
            service_id: this.serviceId,
            merchant_id: this.merchantId,
            amount: amount.toString(),
            transaction_param: orderId,
            return_url: returnUrl,
        });

        return `${this.baseUrl}?${params.toString()}`;
    }

    /**
     * Prepare endpoint - validates order
     */
    async handlePrepare(params: any): Promise<any> {
        this.logger.log('Click prepare request', params);

        // Verify signature
        const signString = `${params.click_trans_id}${params.service_id}${this.secretKey}${params.merchant_trans_id}${params.amount}${params.action}${params.sign_time}`;
        const expectedSign = crypto.createHash('md5').update(signString).digest('hex');

        if (expectedSign !== params.sign_string) {
            return {
                error: -1,
                error_note: 'Invalid signature',
            };
        }

        // Check if order exists and amount is correct
        // This should validate against your orders

        return {
            click_trans_id: params.click_trans_id,
            merchant_trans_id: params.merchant_trans_id,
            merchant_prepare_id: Date.now(),
            error: 0,
            error_note: 'Success',
        };
    }

    /**
     * Complete endpoint - confirms payment
     */
    async handleComplete(params: any): Promise<any> {
        this.logger.log('Click complete request', params);

        // Verify signature
        const signString = `${params.click_trans_id}${params.service_id}${this.secretKey}${params.merchant_trans_id}${params.merchant_prepare_id}${params.amount}${params.action}${params.sign_time}`;
        const expectedSign = crypto.createHash('md5').update(signString).digest('hex');

        if (expectedSign !== params.sign_string) {
            return {
                error: -1,
                error_note: 'Invalid signature',
            };
        }

        // Mark order as paid
        // Update transaction status

        return {
            click_trans_id: params.click_trans_id,
            merchant_trans_id: params.merchant_trans_id,
            merchant_confirm_id: Date.now(),
            error: 0,
            error_note: 'Success',
        };
    }

    /**
     * Verify Click signature
     */
    verifySignature(params: any, action: 'prepare' | 'complete'): boolean {
        try {
            let signString: string;

            if (action === 'prepare') {
                signString = `${params.click_trans_id}${params.service_id}${this.secretKey}${params.merchant_trans_id}${params.amount}${params.action}${params.sign_time}`;
            } else {
                signString = `${params.click_trans_id}${params.service_id}${this.secretKey}${params.merchant_trans_id}${params.merchant_prepare_id}${params.amount}${params.action}${params.sign_time}`;
            }

            const expectedSign = crypto.createHash('md5').update(signString).digest('hex');
            return expectedSign === params.sign_string;
        } catch (error) {
            this.logger.error('Signature verification failed', error);
            return false;
        }
    }
}
