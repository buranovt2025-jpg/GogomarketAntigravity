import {
    Entity,
    PrimaryGeneratedColumn,
    Column,
    CreateDateColumn,
    UpdateDateColumn,
    ManyToOne,
    JoinColumn,
    Index,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Product } from '../../products/entities/product.entity';

@Entity('stories')
@Index(['createdAt'])
@Index(['sellerId'])
export class Story {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column('uuid')
    sellerId: string;

    @ManyToOne(() => User)
    @JoinColumn({ name: 'sellerId' })
    seller: User;

    @Column({ nullable: true })
    productId?: string;

    @ManyToOne(() => Product, { nullable: true })
    @JoinColumn({ name: 'productId' })
    product?: Product;

    @Column({ type: 'text' })
    videoUrl: string;

    @Column({ type: 'text', nullable: true })
    thumbnailUrl?: string;

    @Column({ type: 'text', nullable: true })
    description?: string;

    @Column({ type: 'int', default: 0 })
    viewsCount: number;

    @Column({ type: 'int', default: 0 })
    likesCount: number;

    @Column({ type: 'int', default: 0 })
    sharesCount: number;

    @Column({ type: 'int', default: 0 })
    duration: number; // in seconds

    @Column({ type: 'boolean', default: true })
    isActive: boolean;

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}
