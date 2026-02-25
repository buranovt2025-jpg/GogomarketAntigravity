import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan } from 'typeorm';
import { Story } from './entities/story.entity';
import { StoryLike } from './entities/story-like.entity';
import { StoryView } from './entities/story-view.entity';
import { CreateStoryDto } from './dto/create-story.dto';

@Injectable()
export class StoriesService {
    constructor(
        @InjectRepository(Story)
        private storiesRepository: Repository<Story>,
        @InjectRepository(StoryLike)
        private likesRepository: Repository<StoryLike>,
        @InjectRepository(StoryView)
        private viewsRepository: Repository<StoryView>,
    ) { }

    /**
     * Create a new story
     */
    async create(sellerId: string, createStoryDto: CreateStoryDto): Promise<Story> {
        const story = this.storiesRepository.create({
            ...createStoryDto,
            sellerId,
        });

        return this.storiesRepository.save(story);
    }

    /**
     * Get feed for user (algorithm: recent + popular + following)
     */
    async getFeed(userId: string, limit = 20, offset = 0): Promise<Story[]> {
        // Simple algorithm: get recent active stories, ordered by engagement
        const stories = await this.storiesRepository.find({
            where: {
                isActive: true,
                createdAt: MoreThan(new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)), // Last 7 days
            },
            relations: ['seller', 'product'],
            order: {
                likesCount: 'DESC',
                viewsCount: 'DESC',
                createdAt: 'DESC',
            },
            skip: offset,
            take: limit,
        });

        return stories;
    }

    /**
     * Get stories by seller
     */
    async getBySeller(sellerId: string): Promise<Story[]> {
        return this.storiesRepository.find({
            where: { sellerId },
            relations: ['product'],
            order: { createdAt: 'DESC' },
        });
    }

    /**
     * Get single story
     */
    async findOne(id: string): Promise<Story> {
        const story = await this.storiesRepository.findOne({
            where: { id },
            relations: ['seller', 'product'],
        });

        if (!story) {
            throw new NotFoundException('Story not found');
        }

        return story;
    }

    /**
     * Record view
     */
    async recordView(storyId: string, userId: string, watchDuration: number): Promise<void> {
        // Check if already viewed
        const existingView = await this.viewsRepository.findOne({
            where: { storyId, userId },
        });

        if (!existingView) {
            // Create new view
            const view = this.viewsRepository.create({
                storyId,
                userId,
                watchDuration,
            });
            await this.viewsRepository.save(view);

            // Increment views count
            await this.storiesRepository.increment({ id: storyId }, 'viewsCount', 1);
        }
    }

    /**
     * Toggle like
     */
    async toggleLike(storyId: string, userId: string): Promise<{ liked: boolean }> {
        const existingLike = await this.likesRepository.findOne({
            where: { storyId, userId },
        });

        if (existingLike) {
            // Unlike
            await this.likesRepository.remove(existingLike);
            await this.storiesRepository.decrement({ id: storyId }, 'likesCount', 1);
            return { liked: false };
        } else {
            // Like
            const like = this.likesRepository.create({ storyId, userId });
            await this.likesRepository.save(like);
            await this.storiesRepository.increment({ id: storyId }, 'likesCount', 1);
            return { liked: true };
        }
    }

    /**
     * Check if user liked story
     */
    async isLikedByUser(storyId: string, userId: string): Promise<boolean> {
        const like = await this.likesRepository.findOne({
            where: { storyId, userId },
        });
        return !!like;
    }

    /**
     * Delete story (only owner)
     */
    async delete(id: string, userId: string): Promise<void> {
        const story = await this.findOne(id);

        if (story.sellerId !== userId) {
            throw new ForbiddenException('You can only delete your own stories');
        }

        await this.storiesRepository.remove(story);
    }

    /**
     * Get statistics
     */
    async getStats(sellerId: string): Promise<any> {
        const stories = await this.storiesRepository.find({
            where: { sellerId },
        });

        const totalViews = stories.reduce((sum, s) => sum + s.viewsCount, 0);
        const totalLikes = stories.reduce((sum, s) => sum + s.likesCount, 0);

        return {
            totalStories: stories.length,
            totalViews,
            totalLikes,
            avgViewsPerStory: stories.length > 0 ? totalViews / stories.length : 0,
            avgLikesPerStory: stories.length > 0 ? totalLikes / stories.length : 0,
        };
    }
}
