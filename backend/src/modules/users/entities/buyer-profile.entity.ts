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

@Entity('buyer_profiles')
export class BuyerProfile {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column('uuid')
    userId: string;

    @OneToOne(() => User, (user) => user.buyerProfile, { onDelete: 'CASCADE' })
    @JoinColumn({ name: 'userId' })
    user: User;

    @Column({ nullable: true })
    avatarUrl: string;

    @Column({ nullable: true })
    name: string;

    @Column({ type: 'jsonb', nullable: true })
    addresses: any[];

    @Column({ nullable: true })
    defaultAddressId: string;

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}
