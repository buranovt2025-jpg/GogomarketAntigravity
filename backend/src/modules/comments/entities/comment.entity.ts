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
import { Story } from '../../stories/entities/story.entity';
import { User } from '../../users/entities/user.entity';

@Entity('comments')
@Index(['storyId'])
export class Comment {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column('uuid')
    storyId: string;

    @ManyToOne(() => Story)
    @JoinColumn({ name: 'storyId' })
    story: Story;

    @Column('uuid')
    userId: string;

    @ManyToOne(() => User)
    @JoinColumn({ name: 'userId' })
    user: User;

    @Column({ type: 'text' })
    content: string;

    @Column({ type: 'uuid', nullable: true })
    parentId?: string;

    @ManyToOne(() => Comment, { nullable: true })
    @JoinColumn({ name: 'parentId' })
    parent?: Comment;

    @Column({ type: 'int', default: 0 })
    likesCount: number;

    @CreateDateColumn()
    createdAt: Date;

    @UpdateDateColumn()
    updatedAt: Date;
}
