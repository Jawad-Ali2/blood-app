import { Body, Controller, Get, Param, Post, Query } from '@nestjs/common';
import { UserService } from './user.service';
import { Public } from 'src/common/decorators/public.decorator';
import { bloodTypeCrossMatch } from 'src/constants';
import { filter } from 'rxjs';

@Controller('user')
export class UserController {
  constructor(private readonly userService: UserService) { }

  @Public()
  @Get('donors')
  async getDonors() {
    const donors = await this.userService.getDonors();
    if (!donors || donors.length === 0) {
      return {
        status: 'error',
        message: 'No donors found in this city',
      };
    }
    return {
      status: 'success',
      data: donors,
    };
  }



  @Public()
  @Get('donors/filter')
  async filterDonors(
    @Query('bloodGroup') bloodGroup: string,
    @Query('city') city: string
  ) {
    const donors = await this.getDonors();
    let filteredDonors = donors.data ?? [];

    if (bloodGroup) {
      const compatibleDonors = bloodTypeCrossMatch[bloodGroup] ?? [];
      filteredDonors = filteredDonors?.filter(d => compatibleDonors.includes(d.bloodGroup ?? ''));
    }

    if (city) {
      filteredDonors = filteredDonors.filter(d => (d.city ?? '').toLowerCase() === city.toLowerCase());
    }

    return {
      status: 'success',
      data: filteredDonors,
      count: filteredDonors.length
    };
  }


  @Public()
  @Get('donors/nearby')
  async getNearbyDonors(
    @Query('lat') latitude: string,
    @Query('lng') longitude: string,
    @Query('radius') radius: string = '10',
    @Query('bloodGroup') bloodGroup: string = ""
  ) {
    const donors = await this.getDonors();
    let filteredDonors = donors.data;
    const compatibleDonors = bloodTypeCrossMatch[bloodGroup] ?? [];
    // Filter by blood group if provided
    if (bloodGroup) {
      // Get all the compaticable blood groups for the given blood group
      filteredDonors = filteredDonors?.filter(d => compatibleDonors.includes(d.bloodGroup ?? ''));
    }
    filteredDonors = filteredDonors?.map(donor => {
      const [donorLat, donorLng] = (donor.coordinates ?? '0,0').split(',').map(Number);
      const distance = this.calculateDistance(
        Number(latitude),
        Number(longitude),
        donorLat,
        donorLng
      );

      return {
        ...donor,
        distance: distance.toFixed(2)
      };
    })
      .filter(donor => Number(donor.distance) <= Number(radius))
      .sort((a, b) => Number(a.distance) - Number(b.distance));

    return {
      status: 'success',
      data: filteredDonors,
      count: filteredDonors?.length
    };
  }

  @Public()
  @Get('donors/:id')
  async getDonorById(@Param('id') id: string) {
    const donors = await this.getDonors();
    const donor = (donors.data ?? []).find(d => d.id === id);

    if (!donor) {
      return {
        status: 'error',
        message: 'Donor not found'
      };
    }

    return {
      status: 'success',
      data: donor
    };
  }

  @Public()
  @Post('register-donor')
  async registerDonor(@Param("id") id: string, @Body("bloodGroup") bloodGroup: string) {

    await this.userService.registerDonor(id, bloodGroup);

    return {
      status: 'success',
      message: 'Donor registered successfully'
    };

  }

  // Helper method to calculate distance between coordinates using Haversine formula
  private calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371; // Radius of the Earth in km
    const dLat = this.deg2rad(lat2 - lat1);
    const dLon = this.deg2rad(lon2 - lon1);
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.deg2rad(lat1)) * Math.cos(this.deg2rad(lat2)) *
      Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    const distance = R * c;
    return distance;
  }

  private deg2rad(deg: number): number {
    return deg * (Math.PI / 180);
  }

}
