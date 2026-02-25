import { Injectable, UnauthorizedException, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { UsersService } from '../users/users.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { User, UserRole } from '../users/entities/user.entity';

@Injectable()
export class AuthService {
    constructor(
        private usersService: UsersService,
        private jwtService: JwtService,
        private configService: ConfigService,
    ) { }

    async register(registerDto: RegisterDto) {
        // Check if user already exists
        const existingUser = await this.usersService.findByPhone(registerDto.phone);
        if (existingUser) {
            throw new BadRequestException('User with this phone already exists');
        }

        // Hash password
        const passwordHash = await bcrypt.hash(registerDto.password, 10);

        // Create user
        const user = await this.usersService.create({
            phone: registerDto.phone,
            email: registerDto.email,
            passwordHash,
            role: registerDto.role,
        });

        // Create profile based on role
        if (registerDto.role === UserRole.SELLER) {
            await this.usersService.createSellerProfile(user.id, {
                storeName: registerDto.storeName,
                cabinetType: registerDto.cabinetType,
                category: registerDto.category,
            });
        } else if (registerDto.role === UserRole.BUYER) {
            await this.usersService.createBuyerProfile(user.id, {
                name: registerDto.name,
            });
        }

        // Generate tokens
        const tokens = await this.generateTokens(user);

        return {
            user: this.sanitizeUser(user),
            tokens,
        };
    }

    async login(loginDto: LoginDto) {
        const user = await this.validateUser(loginDto.phone, loginDto.password);

        if (!user) {
            throw new UnauthorizedException('Invalid credentials');
        }

        if (user.isBlocked) {
            throw new UnauthorizedException('Your account has been blocked');
        }

        // Update last login
        await this.usersService.updateLastLogin(user.id);

        const tokens = await this.generateTokens(user);

        return {
            user: this.sanitizeUser(user),
            tokens,
        };
    }

    async validateUser(phone: string, password: string): Promise<User | null> {
        const user = await this.usersService.findByPhone(phone);

        if (!user) {
            return null;
        }

        const isPasswordValid = await bcrypt.compare(password, user.passwordHash);

        if (!isPasswordValid) {
            return null;
        }

        return user;
    }

    async generateTokens(user: User) {
        const payload = { sub: user.id, phone: user.phone, role: user.role };

        const accessToken = this.jwtService.sign(payload);

        const refreshToken = this.jwtService.sign(payload, {
            secret: this.configService.get('JWT_REFRESH_SECRET'),
            expiresIn: this.configService.get('JWT_REFRESH_EXPIRES_IN'),
        });

        return {
            accessToken,
            refreshToken,
            expiresIn: this.configService.get('JWT_EXPIRES_IN'),
        };
    }

    async refreshToken(refreshToken: string) {
        try {
            const payload = this.jwtService.verify(refreshToken, {
                secret: this.configService.get('JWT_REFRESH_SECRET'),
            });

            const user = await this.usersService.findById(payload.sub);

            if (!user || user.isBlocked) {
                throw new UnauthorizedException('Invalid token');
            }

            return await this.generateTokens(user);
        } catch (error) {
            throw new UnauthorizedException('Invalid refresh token');
        }
    }

    private sanitizeUser(user: User) {
        const { passwordHash, ...sanitized } = user;
        return sanitized;
    }
}
