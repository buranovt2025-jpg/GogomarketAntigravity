import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne } from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Entity('messages')
export class Message {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @ManyToOne(() => User)
    sender: User;

    @Column()
    senderId: string;

    @ManyToOne(() => User)
    recipient: User;

    @Column()
    recipientId: string;

    @Column('text')
    content: string;

    @Column({ default: false })
    isRead: boolean;

    @CreateDateColumn()
    createdAt: Date;
}
