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

@Entity('story_views')
@Index(['storyId', 'userId'])
export class StoryView {
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

    @Column({ type: 'int', default: 0 })
    watchDuration: number; // in seconds

    @CreateDateColumn()
    createdAt: Date;
}
