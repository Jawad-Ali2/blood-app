import { Body, Controller, Delete, Get, Post } from '@nestjs/common';
import { ListingService } from './listing.service';

@Controller('listing')
export class ListingController {
  constructor(private readonly listingService: ListingService) {
  }


  @Post()
  async postListing(@Body() body: PostListingDTO) {

    await this.listingService.postListing(body);

  }


  @Get()
  async getAllListings(){
    const listings  = await this.listingService.getListings();

    return listings;
  }

  @Delete()
  async deleteListing(@Body('listingId') id){
    console.log(id);
      await this.listingService.deleteListing(id);
  }
}
