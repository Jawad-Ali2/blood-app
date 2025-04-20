import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Listing } from './entities/listings';
import { Repository } from 'typeorm';
import { PostListingDTO } from './dto/post-listing.dto';
import { User } from 'src/user/entities/user.entity';
import { ListingStatus } from 'src/constants';

@Injectable()
export class ListingService {
  constructor(
    @InjectRepository(Listing)
    private listingRepository: Repository<Listing>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) { }

  async postListing(listingData: PostListingDTO): Promise<Listing> {
    // Find the user
    const user = await this.userRepository.findOne({ where: { id: listingData.userId } });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Get all active listings for this user
    const activeListings = await this.listingRepository.find({
      where: {
        user: { id: listingData.userId },
        status: 'active',
      },
      order: { createdAt: 'ASC' },
    });

    // Check for emergency listing creation restrictions
    if (listingData.isEmergency) {
      // If user already has active listings, throw error - frontend will handle this
      if (activeListings.length > 0) {
        throw new BadRequestException({
          message: 'You have active listings that need to be canceled before creating an emergency request',
          activeListings: activeListings
        });
      }
    } else {
      // For normal listings
      // Check if user has any active emergency listings
      const hasActiveEmergency = activeListings.some(listing => listing.isEmergency);
      if (hasActiveEmergency) {
        throw new BadRequestException('You cannot create a regular listing while you have an active emergency request');
      }

      // Check if user has reached the limit of 2 active regular listings
      if (activeListings.length >= 2) {
        throw new BadRequestException({
          message: 'You can only have 2 active listings at a time',
          activeListings: activeListings
        });
      }
    }

    // Create a new listing
    const newListing = this.listingRepository.create({
      ...listingData,
      requiredTill: new Date(listingData.requiredTill),
      user: user,
      status: 'active', // Default status
    });

    // Save the listing
    return this.listingRepository.save(newListing);
  }

  async cancelAllActiveListings(userId: string): Promise<void> {
    const activeListings = await this.listingRepository.find({
      where: {
        user: { id: userId },
        status: 'active',
      },
    });

    for (const listing of activeListings) {
      listing.status = 'canceled';
      await this.listingRepository.save(listing);
    }
  }

  async cancelOldestListing(userId: string): Promise<Listing | null> {
    const oldestListing = await this.listingRepository.findOne({
      where: {
        user: { id: userId },
        status: 'active',
      },
      order: { createdAt: 'ASC' },
      relations: ['user']
    });

    if (oldestListing) {
      oldestListing.status = 'canceled';
      return this.listingRepository.save(oldestListing);
    }

    return null;
  }

  async updateListingStatus(id: string, status: string): Promise<Listing> {
    try {
      const listing = await this.listingRepository.findOne({
        where: { id },
        relations: ['user']
      });

      if (!listing) {
        throw new NotFoundException(`Listing with ID ${id} not found`);
      }

      listing.status = status;

      return this.listingRepository.save(listing);
    } catch (error) {
      throw new BadRequestException(`Error updating listing status: ${error.message}`);

    }
  }

  async getUserListingsCount(userId: string): Promise<{ active: number, canceled: number, fulfilled: number, total: number }> {
    const listings = await this.listingRepository.find({
      where: { user: { id: userId } }
    });

    const counts = {
      active: listings.filter(l => l.status === 'active').length,
      canceled: listings.filter(l => l.status === 'canceled').length,
      fulfilled: listings.filter(l => l.status === 'fulfilled').length,
      total: listings.length
    };

    return counts;
  }

  async getUserActiveListingsCount(userId: string): Promise<number> {
    const count = await this.listingRepository.count({
      where: {
        user: { id: userId },
        status: 'active'
      }
    });

    return count;
  }

  async getCompatibleListings(bloodGroup: string): Promise<Listing[]> {
    const listings = await this.listingRepository.find({
      where: {
        status: 'active',
        isEmergency: false,
        groupRequired: bloodGroup
      },
      relations: ['user'],
      order: { createdAt: 'DESC' }
    });

    return listings;
  }

  async getListings(): Promise<Listing[]> {
    return this.listingRepository.find({
      relations: ['user'],
      order: { createdAt: 'DESC' }
    });
  }

  async getEmergencyListings(): Promise<Listing[]> {
    return this.listingRepository.find({
      where: { isEmergency: true },
      relations: ['user'],
      order: { createdAt: 'DESC' }
    });
  }

  async getUserListings(userId: string): Promise<Listing[]> {
    return this.listingRepository.find({
      where: { user: { id: userId } },
      relations: ['user'],
      order: { createdAt: 'DESC' }
    });
  }

  async deleteListing(id: string): Promise<void> {
    const result = await this.listingRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException(`Listing with ID ${id} not found`);
    }
  }

  async addListingToDonorActiveRequests(listingId: string, userId: string): Promise<Listing> {
    try {
      // Find the listing with relations to see current acceptedBy
      const listing = await this.listingRepository.findOne({ 
        where: { id: listingId },
        relations: ['acceptedBy', 'user'] 
      });
      
      if (!listing) {
        throw new NotFoundException(`Listing with ID ${listingId} not found`);
      }

      // Check if listing is in active state
      if (listing.status !== ListingStatus.ACTIVE) {
        throw new BadRequestException(`This listing is not available for donation. Current status: ${listing.status}`);
      }

      // Check if listing is already accepted by another donor
      if (listing.acceptedBy) {
        throw new BadRequestException('This request is already being fulfilled by another donor');
      }

      // Find the donor user with blood type information
      const donor = await this.userRepository.findOne({ where: { id: userId } });
      if (!donor) {
        throw new NotFoundException(`Donor with ID ${userId} not found`);
      }

      // Check if donor's blood type is compatible with the request
      if (!this.isBloodTypeCompatible(donor.bloodGroup, listing.groupRequired)) {
        throw new BadRequestException(
          `Blood type incompatible. Your blood type (${donor.bloodGroup}) cannot be donated for ${listing.groupRequired} requests.`
        );
      }

      // Assign donor to the listing and change status
      listing.acceptedBy = donor;
      listing.status = ListingStatus.IN_PROGRESS;
      
      // Return the updated listing
      return await this.listingRepository.save(listing);
    } catch (error) {
      // More specific error handling
      if (error instanceof NotFoundException || error instanceof BadRequestException) {
        throw error;
      }
      throw new BadRequestException(`Failed to accept blood request: ${error.message}`);
    }
  }

  // Helper method to check blood type compatibility
  private isBloodTypeCompatible(donorType: string, requestedType: string): boolean {
    // Blood type compatibility rules (donor -> recipient)
    const compatibilityMap = {
      'O-': ['O-', 'O+', 'A-', 'A+', 'B-', 'B+', 'AB-', 'AB+'],
      'O+': ['O+', 'A+', 'B+', 'AB+'],
      'A-': ['A-', 'A+', 'AB-', 'AB+'],
      'A+': ['A+', 'AB+'],
      'B-': ['B-', 'B+', 'AB-', 'AB+'],
      'B+': ['B+', 'AB+'],
      'AB-': ['AB-', 'AB+'],
      'AB+': ['AB+'],
    };
    
    return compatibilityMap[donorType]?.includes(requestedType) || false;
  }
}
