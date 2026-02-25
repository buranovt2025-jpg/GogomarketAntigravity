import {
    Entity,
    PrimaryGeneratedColumn,
    Column,
    CreateDateColumn,
    UpdateDateColumn,
    OneToOne,
    JoinColumn,
} from 'typeorm';
import { User } from './user.entity';

export enum CabinetType {
    FULL = 'full',
    SIMPLIFIED = 'simplified',
}

export enum VerificationStatus {
    PENDING = 'pending',
    APPROVED = 'approved',
    REJECTED = 'rejected',
}

export enum SimplifiedCategory {
    AUTO = 'auto',
    REALESTATE = 'realestate',
    SERVICES = 'services',
}

@Entity('seller_profiles')
export class SellerProfile {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column('uuid')
    userId: string;

    @OneToOne(() => User, (user) => user.sellerProfile, { onDelete: 'CASCADE' })
    @JoinColumn({ name: 'userId' })
    user: User;

    @Column({
        type: 'enum',
        enum: CabinetType,
    })
    cabinetType: CabinetType;

    @Column()
    storeName: string;

    @Column({ type: 'text', nullable: true })
    description: string;

    @Column({ nullable: true })
    logoUrl: string;

    @Column({
        type: 'enum',
        enum: SimplifiedCategory,
        nullable: true,
    })
    category: SimplifiedCategory;

    @Column({ type: 'decimal', precision: 3, scale: 2, default: 0 })
    rating: number;

    @Column({ default: 0 })
    totalReviews: number;

    @Column({ default: false })
    isOnline: boolean;

    @Column({
        type: 'enum',
        enum: VerificationStatus,
        default: VerificationStatus.PENDING,
    })
    verificationStatus: VerificationStatus;

    @Column({ type: 'jsonb', nullable: true })
    verificationDocuments: any;

    @Column({ type: 'decimal', precision: 12, scale: 2, default: 0 })
    balance: number;

    @Column({ type: 'decimal', precision: 12, scale: 2, default: 0 })
    totalSales: number;

    @Column({ default: 0 })
    followersCount: number;

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}
