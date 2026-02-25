import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User, UserRole } from './entities/user.entity';
import { SellerProfile } from './entities/seller-profile.entity';
import { BuyerProfile } from './entities/buyer-profile.entity';

@Injectable()
export class UsersService {
    constructor(
        @InjectRepository(User)
        private usersRepository: Repository<User>,
        @InjectRepository(SellerProfile)
        private sellerProfileRepository: Repository<SellerProfile>,
        @InjectRepository(BuyerProfile)
        private buyerProfileRepository: Repository<BuyerProfile>,
    ) { }

    async create(userData: Partial<User>): Promise<User> {
        const user = this.usersRepository.create(userData);
        return this.usersRepository.save(user);
    }

    async findById(id: string): Promise<User | null> {
        return this.usersRepository.findOne({
            where: { id },
            relations: ['sellerProfile', 'buyerProfile'],
        });
    }

    async findByPhone(phone: string): Promise<User | null> {
        return this.usersRepository.findOne({
            where: { phone },
        });
    }

    async findByEmail(email: string): Promise<User | null> {
        return this.usersRepository.findOne({
            where: { email },
        });
    }

    async updateLastLogin(userId: string): Promise<void> {
        await this.usersRepository.update(userId, {
            lastLoginAt: new Date(),
        });
    }

    async createSellerProfile(userId: string, profileData: Partial<SellerProfile>): Promise<SellerProfile> {
        const profile = this.sellerProfileRepository.create({
            ...profileData,
            userId,
        });
        return this.sellerProfileRepository.save(profile);
    }

    async createBuyerProfile(userId: string, profileData: Partial<BuyerProfile>): Promise<BuyerProfile> {
        const profile = this.buyerProfileRepository.create({
            ...profileData,
            userId,
        });
        return this.buyerProfileRepository.save(profile);
    }

    async getSellerProfile(userId: string): Promise<SellerProfile | null> {
        return this.sellerProfileRepository.findOne({
            where: { userId },
        });
    }

    async getBuyerProfile(userId: string): Promise<BuyerProfile | null> {
        return this.buyerProfileRepository.findOne({
            where: { userId },
        });
    }

    async updateSellerProfile(userId: string, updateData: Partial<SellerProfile>): Promise<SellerProfile> {
        await this.sellerProfileRepository.update({ userId }, updateData);
        return this.getSellerProfile(userId);
    }

    async updateBuyerProfile(userId: string, updateData: Partial<BuyerProfile>): Promise<BuyerProfile> {
        await this.buyerProfileRepository.update({ userId }, updateData);
        return this.getBuyerProfile(userId);
    }

    async findAll(page: number = 1, limit: number = 10): Promise<[User[], number]> {
        return this.usersRepository.findAndCount({
            skip: (page - 1) * limit,
            take: limit,
            relations: ['sellerProfile', 'buyerProfile'],
            order: { createdAt: 'DESC' },
        });
    }

    async countUsers(): Promise<number> {
        return this.usersRepository.count();
    }

    async updateBlockedStatus(userId: string, isBlocked: boolean): Promise<User> {
        await this.usersRepository.update(userId, { isBlocked });
        return this.findById(userId);
    }

    async updateRole(userId: string, role: UserRole): Promise<User> {
        await this.usersRepository.update(userId, { role });
        return this.findById(userId);
    }
}
