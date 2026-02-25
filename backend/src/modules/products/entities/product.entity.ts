import {
    Entity,
    PrimaryGeneratedColumn,
    Column,
    CreateDateColumn,
    UpdateDateColumn,
    ManyToOne,
    JoinColumn,
} from 'typeorm';
import { SellerProfile } from '../../users/entities/seller-profile.entity';

@Entity('categories')
export class Category {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column({ type: 'jsonb' })
    name: {
        ru: string;
        uz: string;
        en: string;
    };

    @Column({ unique: true })
    slug: string;

    @Column({ nullable: true })
    parentId: string;

    @ManyToOne(() => Category, { nullable: true })
    @JoinColumn({ name: 'parentId' })
    parent: Category;

    @Column({ nullable: true })
    icon: string;

    @Column({ default: 0 })
    order: number;

    @Column({ default: true })
    isActive: boolean;

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}

@Entity('products')
export class Product {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column('uuid')
    sellerId: string;

    @ManyToOne(() => SellerProfile)
    @JoinColumn({ name: 'sellerId' })
    seller: SellerProfile;

    @Column()
    name: string;

    @Column({ type: 'text' })
    description: string;

    @Column({ type: 'decimal', precision: 12, scale: 2 })
    price: number;

    @Column({ type: 'decimal', precision: 12, scale: 2, nullable: true })
    oldPrice: number;

    @Column('uuid')
    categoryId: string;

    @ManyToOne(() => Category)
    @JoinColumn({ name: 'categoryId' })
    category: Category;

    @Column({ type: 'jsonb', default: [] })
    images: string[];

    @Column({ nullable: true })
    videoUrl: string;

    @Column({ type: 'jsonb', nullable: true })
    attributes: Record<string, any>;

    @Column({ default: 0 })
    stockQuantity: number;

    @Column({ default: true })
    isActive: boolean;

    @Column({ type: 'decimal', precision: 3, scale: 2, default: 0 })
    rating: number;

    @Column({ default: 0 })
    reviewsCount: number;

    @Column({ default: 0 })
    viewsCount: number;

    @Column({ default: 0 })
    ordersCount: number;

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}
