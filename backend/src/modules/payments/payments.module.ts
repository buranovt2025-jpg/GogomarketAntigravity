import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PaymentsController } from './payments.controller';
import { PaymentsService } from './payments.service';
import { Transaction } from './entities/transaction.entity';
import { PaymeService } from './services/payme.service';
import { ClickService } from './services/click.service';
import { OrdersModule } from '../orders/orders.module';

@Module({
    imports: [
        TypeOrmModule.forFeature([Transaction]),
        OrdersModule,
    ],
    controllers: [PaymentsController],
    providers: [PaymentsService, PaymeService, ClickService],
    exports: [PaymentsService],
})
export class PaymentsModule { }
