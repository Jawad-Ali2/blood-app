import { Body, Controller, Delete, Get, Post } from '@nestjs/common';
import { ListingService } from './listing.service';
import { Public } from 'src/common/decorators/public.decorator';

@Controller('listing')
export class ListingController {
  constructor(private readonly listingService: ListingService) {
  }


  @Post()
  async postListing(@Body() body: PostListingDTO) {

    await this.listingService.postListing(body);

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
        user: { id: 'user1' },
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
        user: { id: 'user2' },
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
        user: { id: 'user2' },
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

  @Delete()
  async deleteListing(@Body('listingId') id) {
    console.log(id);
    await this.listingService.deleteListing(id);
  }
}
