import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { UsersService } from './users.service';
import { User } from './entities/user.entity';
import { SellerProfile } from './entities/seller-profile.entity';
import { BuyerProfile } from './entities/buyer-profile.entity';
import { Repository } from 'typeorm';

describe('UsersService', () => {
    let service: UsersService;
    let userRepository: Repository<User>;

    const mockUserRepository = {
        create: jest.fn(),
        save: jest.fn(),
        findOne: jest.fn(),
        update: jest.fn(),
        findAndCount: jest.fn(),
        count: jest.fn(),
    };

    const mockSellerProfileRepository = {};
    const mockBuyerProfileRepository = {};

    beforeEach(async () => {
        const module: TestingModule = await Test.createTestingModule({
            providers: [
                UsersService,
                {
                    provide: getRepositoryToken(User),
                    useValue: mockUserRepository,
                },
                {
                    provide: getRepositoryToken(SellerProfile),
                    useValue: mockSellerProfileRepository,
                },
                {
                    provide: getRepositoryToken(BuyerProfile),
                    useValue: mockBuyerProfileRepository,
                },
            ],
        }).compile();

        service = module.get<UsersService>(UsersService);
        userRepository = module.get<Repository<User>>(getRepositoryToken(User));
    });

    it('should be defined', () => {
        expect(service).toBeDefined();
    });

    describe('findById', () => {
        it('should return a user if found', async () => {
            const user = { id: 'test-id', phone: '123' } as User;
            mockUserRepository.findOne.mockResolvedValue(user);

            const result = await service.findById('test-id');
            expect(result).toEqual(user);
            expect(mockUserRepository.findOne).toHaveBeenCalledWith({
                where: { id: 'test-id' },
                relations: ['sellerProfile', 'buyerProfile'],
            });
        });
    });

    describe('updateBlockedStatus', () => {
        it('should update block status and return updated user', async () => {
            const userId = 'user-id';
            const user = { id: userId, isBlocked: true } as User;
            mockUserRepository.update.mockResolvedValue({ affected: 1 });
            mockUserRepository.findOne.mockResolvedValue(user);

            const result = await service.updateBlockedStatus(userId, true);
            expect(mockUserRepository.update).toHaveBeenCalledWith(userId, { isBlocked: true });
            expect(result.isBlocked).toBe(true);
        });
    });
});
