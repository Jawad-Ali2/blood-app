import { Injectable, InternalServerErrorException, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { User } from './entities/user.entity';
import { Repository } from 'typeorm';

@Injectable()
export class UserService {
    constructor(
        @InjectRepository(User)
        private userRepository: Repository<User>
    ) { }

    async registerDonor(userId: string, bloodGroup: string): Promise<void> {
        const user = await this.userRepository.findOneBy({ id: userId });

        if (!user) {
            throw new NotFoundException('User not found');
        }

        try {
            user.isDonor = true;
            user.bloodGroup = bloodGroup;
            user.credibilityPoints = 0;
            if (!user.role.includes('donor')) {
                user.role.push('donor');
            }
            await this.userRepository.save(user);
        } catch (error) {
            throw new InternalServerErrorException('Error registering donor', error.message);
        }

    }

    async getDonors(): Promise<Partial<User>[]> {
        const donors = await this.userRepository.find({
            where: {
                isDonor: true,
            },
            select: [
                'id',
                'username',
                'email',
                'bloodGroup',
                'phone',
                'coordinates',
                'lastDonationDate',
                'credibilityPoints',
                'isVerified'
            ],
        });

        return donors;
    }
}
