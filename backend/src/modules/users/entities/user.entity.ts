import {
    Entity,
    PrimaryGeneratedColumn,
    Column,
    CreateDateColumn,
    UpdateDateColumn,
    OneToOne,
} from 'typeorm';
import { Exclude } from 'class-transformer';
import { SellerProfile } from './seller-profile.entity';
import { BuyerProfile } from './buyer-profile.entity';

export enum UserRole {
    SELLER = 'seller',
    BUYER = 'buyer',
    COURIER = 'courier',
    ADMIN = 'admin',
}

@Entity('users')
export class User {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column({ unique: true })
    phone: string;

    @Column({ unique: true, nullable: true })
    email: string;

    @Column()
    @Exclude()
    passwordHash: string;

    @Column({
        type: 'enum',
        enum: UserRole,
    })
    role: UserRole;

    @Column({ default: false })
    isVerified: boolean;

    @Column({ default: false })
    isBlocked: boolean;

    @Column({ nullable: true })
    lastLoginAt: Date;

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;

    // Relations
    @OneToOne(() => SellerProfile, (profile) => profile.user, { nullable: true })
    sellerProfile?: SellerProfile;

    @OneToOne(() => BuyerProfile, (profile) => profile.user, { nullable: true })
    buyerProfile?: BuyerProfile;
}
