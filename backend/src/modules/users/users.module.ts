import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { User } from './entities/user.entity';
import { SellerProfile } from './entities/seller-profile.entity';
import { BuyerProfile } from './entities/buyer-profile.entity';

@Module({
    imports: [TypeOrmModule.forFeature([User, SellerProfile, BuyerProfile])],
    controllers: [UsersController],
    providers: [UsersService],
    exports: [UsersService],
})
export class UsersModule { }
