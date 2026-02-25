import {
    Entity,
    PrimaryGeneratedColumn,
    Column,
    CreateDateColumn,
    ManyToOne,
    JoinColumn,
    Index,
} from 'typeorm';
import { Story } from './story.entity';
import { User } from '../../users/entities/user.entity';

@Entity('story_likes')
@Index(['storyId', 'userId'], { unique: true })
export class StoryLike {
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

    @CreateDateColumn()
    createdAt: Date;
}
