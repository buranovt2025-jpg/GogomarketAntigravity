import {
    Controller,
    Post,
    Get,
    Body,
    Param,
    Query,
    Headers,
    BadRequestException,
    UseGuards,
    Request,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { PaymentsService } from './payments.service';
import { PaymeService } from './services/payme.service';
import { ClickService } from './services/click.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { PaymentProvider } from './entities/transaction.entity';

@ApiTags('payments')
@Controller('payments')
export class PaymentsController {
    constructor(
        private paymentsService: PaymentsService,
        private paymeService: PaymeService,
        private clickService: ClickService,
    ) { }

    @Post('create-link')
    @UseGuards(JwtAuthGuard)
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Create payment link for order' })
    @ApiResponse({ status: 200, description: 'Payment link created' })
    async createPaymentLink(
        @Body() body: { orderId: string; provider: PaymentProvider; returnUrl: string },
    ) {
        const link = await this.paymentsService.createPaymentLink(
            body.orderId,
            body.provider,
            body.returnUrl,
        );

        return { paymentLink: link };
    }

    @Get('order/:orderId')
    @UseGuards(JwtAuthGuard)
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Get all transactions for order' })
    @ApiResponse({ status: 200, description: 'Transactions retrieved' })
    async getOrderTransactions(@Param('orderId') orderId: string) {
        return this.paymentsService.getOrderTransactions(orderId);
    }

    @Get('transaction/:transactionId')
    @UseGuards(JwtAuthGuard)
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Get transaction details' })
    @ApiResponse({ status: 200, description: 'Transaction retrieved' })
    async getTransaction(@Param('transactionId') transactionId: string) {
        return this.paymentsService.getTransaction(transactionId);
    }

    /**
     * Payme webhook endpoint (JSON-RPC)
     */
    @Post('payme/callback')
    @ApiOperation({ summary: 'Payme webhook callback (JSON-RPC)' })
    async paymeCallback(@Headers('authorization') authorization: string, @Body() body: any) {
        // Verify signature
        if (!this.paymeService.verifySignature(authorization)) {
            throw new BadRequestException({
                jsonrpc: '2.0',
                id: body.id,
                error: {
                    code: -32504,
                    message: 'Invalid signature',
                },
            });
        }

        try {
            const result = await this.paymeService.handleCallback(body.method, body.params, body.id);

            return {
                jsonrpc: '2.0',
                id: body.id,
                result,
            };
        } catch (error) {
            return {
                jsonrpc: '2.0',
                id: body.id,
                error: {
                    code: -32400,
                    message: error.message || 'Internal error',
                },
            };
        }
    }

    /**
     * Click prepare endpoint
     */
    @Post('click/prepare')
    @ApiOperation({ summary: 'Click prepare callback' })
    async clickPrepare(@Body() body: any) {
        return this.clickService.handlePrepare(body);
    }

    /**
     * Click complete endpoint
     */
    @Post('click/complete')
    @ApiOperation({ summary: 'Click complete callback' })
    async clickComplete(@Body() body: any) {
        return this.clickService.handleComplete(body);
    }
}
