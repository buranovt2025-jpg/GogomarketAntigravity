import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Comment } from './entities/comment.entity';
import { CreateCommentDto } from './dto/create-comment.dto';

@Injectable()
export class CommentsService {
    constructor(
        @InjectRepository(Comment)
        private commentsRepository: Repository<Comment>,
    ) { }

    /**
     * Create a comment
     */
    async create(userId: string, createCommentDto: CreateCommentDto): Promise<Comment> {
        const comment = this.commentsRepository.create({
            ...createCommentDto,
            userId,
        });

        return this.commentsRepository.save(comment);
    }

    /**
     * Get comments for a story
     */
    async getByStory(storyId: string, limit = 50, offset = 0): Promise<Comment[]> {
        return this.commentsRepository.find({
            where: { storyId, parentId: null }, // Only top-level comments
            relations: ['user'],
            order: { createdAt: 'DESC' },
            skip: offset,
            take: limit,
        });
    }

    /**
     * Get replies to a comment
     */
    async getReplies(parentId: string): Promise<Comment[]> {
        return this.commentsRepository.find({
            where: { parentId },
            relations: ['user'],
            order: { createdAt: 'ASC' },
        });
    }

    /**
     * Delete comment (only owner)
     */
    async delete(id: string, userId: string): Promise<void> {
        const comment = await this.commentsRepository.findOne({
            where: { id },
        });

        if (!comment) {
            throw new NotFoundException('Comment not found');
        }

        if (comment.userId !== userId) {
            throw new ForbiddenException('You can only delete your own comments');
        }

        await this.commentsRepository.remove(comment);
    }

    /**
     * Get comments count for a story
     */
    async getCount(storyId: string): Promise<number> {
        return this.commentsRepository.count({
            where: { storyId },
        });
    }
}
