import { Injectable } from '@nestjs/common';
import { Listing } from './entities/listings';
import { Repository } from 'typeorm';
import { InjectRepository } from '@nestjs/typeorm';
import { User } from 'src/user/entities/user.entity';

@Injectable()
export class ListingService {

    constructor(@InjectRepository(Listing) private listingRepository: Repository<Listing>, @InjectRepository(User) private userRepository: Repository<User>) { }


    async postListing(listingDetails: PostListingDTO) {
        const { bagsRequired, groupRequired, location, pickAndDrop, requiredTill, willPay, userId } = listingDetails;

        // const user = await this.userRepository.findBy({ id: userId });
        // console.log(user);

        const listing = this.listingRepository.create({
            location,
            groupRequired,
            bagsRequired,
            requiredTill,
            pickAndDrop,
            willPay,
            // user: "dgskgajdgkg",
            user: { id: userId },
        });


        const savedLists = await this.listingRepository.save(listing);
        console.log(savedLists);
    }

    async getListings() {

        const listings = await this.listingRepository.find();

        return listings;
    }

    async deleteListing(id: string) {

        const listing = await this.listingRepository.findOne({ where: { id } });

        if (!listing)
            return {
                success: false,
                message: `No Listing Found Corresponding ID: ${id}.`
            }

        await this.listingRepository.remove(listing);

        return {
            success: true,
            message: `Listing with id ${id} has been deleted successfully.`
        };
    }
}
