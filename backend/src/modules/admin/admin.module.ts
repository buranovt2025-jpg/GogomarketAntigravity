import { Module } from '@nestjs/common';
import { AdminController } from './admin.controller';
import { UsersModule } from '../users/users.module';
import { OrdersModule } from '../orders/orders.module';

@Module({
    imports: [
        UsersModule,
        OrdersModule,
    ],
    controllers: [AdminController],
})
export class AdminModule { }
