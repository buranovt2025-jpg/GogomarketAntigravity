import { Injectable, BadRequestException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { S3Client, PutObjectCommand, DeleteObjectCommand } from '@aws-sdk/client-s3';
import * as sharp from 'sharp';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class MediaService {
    private s3Client: S3Client;
    private bucketName: string;
    private cdnUrl: string;

    constructor(private configService: ConfigService) {
        this.s3Client = new S3Client({
            endpoint: this.configService.get('DO_SPACES_ENDPOINT'),
            region: 'fra1',
            credentials: {
                accessKeyId: this.configService.get('DO_SPACES_KEY'),
                secretAccessKey: this.configService.get('DO_SPACES_SECRET'),
            },
        });

        this.bucketName = this.configService.get('DO_SPACES_BUCKET');
        this.cdnUrl = this.configService.get('DO_CDN_URL');
    }

    async uploadImage(file: Express.Multer.File): Promise<{ url: string; thumbnailUrl: string }> {
        // Validate file type
        const allowedTypes = ['image/jpeg', 'image/png', 'image/webp'];
        if (!allowedTypes.includes(file.mimetype)) {
            throw new BadRequestException('Only JPEG, PNG, and WebP images are allowed');
        }

        const fileName = `${uuidv4()}.webp`;
        const thumbnailFileName = `${uuidv4()}-thumb.webp`;

        // Compress main image
        const compressedImage = await sharp(file.buffer)
            .webp({ quality: 85 })
            .resize(1200, 1200, { fit: 'inside', withoutEnlargement: true })
            .toBuffer();

        // Create thumbnail
        const thumbnail = await sharp(file.buffer)
            .webp({ quality: 80 })
            .resize(300, 300, { fit: 'cover' })
            .toBuffer();

        // Upload main image
        await this.s3Client.send(
            new PutObjectCommand({
                Bucket: this.bucketName,
                Key: `products/${fileName}`,
                Body: compressedImage,
                ContentType: 'image/webp',
                ACL: 'public-read',
            }),
        );

        // Upload thumbnail
        await this.s3Client.send(
            new PutObjectCommand({
                Bucket: this.bucketName,
                Key: `products/thumbnails/${thumbnailFileName}`,
                Body: thumbnail,
                ContentType: 'image/webp',
                ACL: 'public-read',
            }),
        );

        return {
            url: `${this.cdnUrl}/products/${fileName}`,
            thumbnailUrl: `${this.cdnUrl}/products/thumbnails/${thumbnailFileName}`,
        };
    }

    async uploadVideo(file: Express.Multer.File): Promise<{ url: string }> {
        // Validate file type
        const allowedTypes = ['video/mp4', 'video/quicktime'];
        if (!allowedTypes.includes(file.mimetype)) {
            throw new BadRequestException('Only MP4 and MOV videos are allowed');
        }

        const maxSize = 100 * 1024 * 1024; // 100MB
        if (file.size > maxSize) {
            throw new BadRequestException('Video size must be less than 100MB');
        }

        const fileName = `${uuidv4()}.mp4`;

        // Upload video (no compression for now, will be done by worker later)
        await this.s3Client.send(
            new PutObjectCommand({
                Bucket: this.bucketName,
                Key: `videos/${fileName}`,
                Body: file.buffer,
                ContentType: file.mimetype,
                ACL: 'public-read',
            }),
        );

        return {
            url: `${this.cdnUrl}/videos/${fileName}`,
        };
    }

    async deleteFile(fileUrl: string): Promise<void> {
        // Extract key from URL
        const key = fileUrl.replace(this.cdnUrl + '/', '');

        await this.s3Client.send(
            new DeleteObjectCommand({
                Bucket: this.bucketName,
                Key: key,
            }),
        );
    }
}
