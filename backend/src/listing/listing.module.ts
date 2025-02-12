import { Module } from '@nestjs/common';
import { ListingService } from './listing.service';
import { ListingController } from './listing.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Listing } from './entities/listings';
import { User } from 'src/user/entities/user.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([Listing, User]),
  ],
  controllers: [ListingController],
  providers: [ListingService],
})
export class ListingModule { }
