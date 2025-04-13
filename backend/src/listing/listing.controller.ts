import { Body, Controller, Delete, Get, Param, Post, Query, BadRequestException } from '@nestjs/common';
import { ListingService } from './listing.service';
import { Public } from 'src/common/decorators/public.decorator';
import { PostListingDTO } from './dto/post-listing.dto';

@Controller('listing')
export class ListingController {
  constructor(private readonly listingService: ListingService) {
  }

  @Post()
  async postListing(@Body() body: PostListingDTO) {
    try {
      const result = await this.listingService.postListing(body);
      return { success: true, data: result };
    } catch (error) {
      // Forward the error with active listings if that's what we received
      if (error instanceof BadRequestException) {
        const response = error.getResponse();
        if (typeof response === 'object' && 'activeListings' in response) {
          throw error;
        }
      }
      throw error;
    }
  }

  @Post('emergency')
  async postEmergencyListing(@Body() body: PostListingDTO) {
    body.isEmergency = true;
    try {
      const result = await this.listingService.postListing(body);
      return { success: true, data: result };
    } catch (error) {
      // Forward the error with active listings if that's what we received
      if (error instanceof BadRequestException) {
        const response = error.getResponse();
        if (typeof response === 'object' && 'activeListings' in response) {
          throw error;
        }
      }
      throw error;
    }
  }

  @Public()
  @Get('dummyListings')
  async getDummyListings() {
    const dummyData = [
      {
        id: '1',
        location: { latitude: 31.5497, longitude: 74.3436 },
        groupRequired: 'Group A',
        bagsRequired: 2,
        requiredTill: new Date('2023-12-31'),
        pickAndDrop: true,
        willPay: false,
        hospitalName: 'City Hospital',
        address: '123 Main St, Lahore',
        isEmergency: false,
        notes: 'Need for surgery',
        user: { id: 'user1', username: 'John Doe' },
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        id: '2',
        location: { latitude: 31.5497, longitude: 74.3436 },
        groupRequired: 'Group B',
        bagsRequired: 3,
        requiredTill: new Date('2023-12-31'),
        pickAndDrop: false,
        willPay: true,
        hospitalName: 'General Hospital',
        address: '456 Park Ave, Lahore',
        isEmergency: true,
        notes: 'Emergency case',
        user: { id: 'user2', username: 'Jane Smith' },
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        id: '3',
        location: { latitude: 31.309428, longitude: 74.204339 },
        groupRequired: 'Group B',
        bagsRequired: 3,
        requiredTill: new Date('2023-12-31'),
        pickAndDrop: false,
        willPay: true,
        hospitalName: 'Central Hospital',
        address: '789 West St, Lahore',
        isEmergency: false,
        notes: 'For scheduled transfusion',
        user: { id: 'user2', username: 'Jane Smith' },
        createdAt: new Date(),
        updatedAt: new Date(),
      },
    ]

    return dummyData;
  }

  @Get()
  async getAllListings() {
    const listings = await this.listingService.getListings();
    return listings;
  }

  @Get('emergency')
  async getEmergencyListings() {
    const listings = await this.listingService.getEmergencyListings();
    return listings;
  }

  @Get('user/:userId')
  async getUserListings(@Param('userId') userId: string) {
    const listings = await this.listingService.getUserListings(userId);
    return listings;
  }

  @Get('count/:userId')
  async getUserListingsCount(@Param('userId') userId: string) {
    const count = await this.listingService.getUserListingsCount(userId);
    return { success: true, count };
  }

  @Post('status/:id')
  async updateListingStatus(
    @Param('id') id: string,
    @Body('status') status: string,
  ) {
    const validStatuses = ['active', 'canceled', 'fulfilled'];
    if (!validStatuses.includes(status)) {
      return { 
        success: false, 
        message: 'Invalid status. Must be one of: active, canceled, fulfilled' 
      };
    }
    
    const result = await this.listingService.updateListingStatus(id, status);
    return { success: true, data: result };
  }

  @Post('cancel-all/:userId')
  async cancelAllActiveListings(@Param('userId') userId: string) {
    await this.listingService.cancelAllActiveListings(userId);
    return { success: true, message: 'All active listings canceled' };
  }

  @Post('cancel-oldest/:userId')
  async cancelOldestListing(@Param('userId') userId: string) {
    const canceledListing = await this.listingService.cancelOldestListing(userId);
    if (canceledListing) {
      return { success: true, data: canceledListing, message: 'Oldest listing canceled' };
    }
    return { success: false, message: 'No active listings found to cancel' };
  }

  @Delete()
  async deleteListing(@Body('listingId') id) {
    console.log(id);
    await this.listingService.deleteListing(id);
    return { success: true };
  }
}
