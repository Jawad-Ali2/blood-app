import { Controller, Get, Param, Query } from '@nestjs/common';
import { UserService } from './user.service';
import { Public } from 'src/common/decorators/public.decorator';

@Controller('user')
export class UserController {
  constructor(private readonly userService: UserService) { }

  @Public()
  @Get('donors')
  async getDonors() {
    // Return dummy donor data - all from Lahore, Pakistan with nearby coordinates
    const donors = [
      {
        id: '1',
        username: 'John Doe',
        email: 'john@example.com',
        bloodGroup: 'A+',
        phone: '0300-1234567',
        city: 'Lahore',
        coordinates: '31.5204,74.3587', // Lahore central coordinates
        dateOfBirth: '1990-05-15',
        isDonor: true,
        lastDonationDate: '2023-08-10',
        credibilityPoints: 85,
        isVerified: true
      },
      {
        id: '2',
        username: 'Sara Khan',
        email: 'sara@example.com',
        bloodGroup: 'O-',
        phone: '0321-9876543',
        city: 'Lahore',
        coordinates: '31.5294,74.3419', // About 2km from central Lahore
        dateOfBirth: '1995-11-20',
        isDonor: true,
        lastDonationDate: '2023-09-05',
        credibilityPoints: 90,
        isVerified: true
      },
      {
        id: '3',
        username: 'Ali Ahmed',
        email: 'ali@example.com',
        bloodGroup: 'B+',
        phone: '0333-1112233',
        city: 'Lahore',
        coordinates: '31.5103,74.3426', // About 1.5km from central Lahore
        dateOfBirth: '1988-07-12',
        isDonor: true,
        lastDonationDate: '2023-07-15',
        credibilityPoints: 75,
        isVerified: true
      },
      {
        id: '4',
        username: 'Fatima Hassan',
        email: 'fatima@example.com',
        bloodGroup: 'AB+',
        phone: '0345-3334455',
        city: 'Lahore',
        coordinates: '31.5312,74.3678', // About 1.8km from central Lahore
        dateOfBirth: '1992-03-25',
        isDonor: true,
        lastDonationDate: '2023-10-01',
        credibilityPoints: 80,
        isVerified: true
      },
      {
        id: '5',
        username: 'Ahmed Khan',
        email: 'ahmed@example.com',
        bloodGroup: 'A-',
        phone: '0312-5556677',
        city: 'Lahore',
        coordinates: '31.5182,74.3727', // About 1.2km from central Lahore
        dateOfBirth: '1985-12-10',
        isDonor: true,
        lastDonationDate: '2023-06-20',
        credibilityPoints: 95,
        isVerified: true
      },
      {
        id: '6',
        username: 'Zainab Malik',
        email: 'zainab@example.com',
        bloodGroup: 'O+',
        phone: '0333-7778889',
        city: 'Lahore',
        coordinates: '31.5385,74.3423', // About 2.5km from central Lahore
        dateOfBirth: '1993-09-18',
        isDonor: true,
        lastDonationDate: '2023-09-25',
        credibilityPoints: 88,
        isVerified: true
      },
      {
        id: '7',
        username: 'Usman Shah',
        email: 'usman@example.com',
        bloodGroup: 'B-',
        phone: '0301-4445556',
        city: 'Lahore',
        coordinates: '31.5154,74.3401', // About 1.7km from central Lahore
        dateOfBirth: '1991-04-30',
        isDonor: true,
        lastDonationDate: '2023-10-12',
        credibilityPoints: 92,
        isVerified: true
      }
    ];

    return {
      status: 'success',
      data: donors
    };
  }


  @Public()
  @Get('donors/filter')
  async filterDonors(
    @Query('bloodGroup') bloodGroup: string,
    @Query('city') city: string
  ) {
    const donors = await this.getDonors();
    let filteredDonors = donors.data;

    if (bloodGroup) {
      filteredDonors = filteredDonors.filter(d => d.bloodGroup === bloodGroup);
    }

    if (city) {
      filteredDonors = filteredDonors.filter(d => d.city.toLowerCase() === city.toLowerCase());
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
    @Query('radius') radius: string = '10', // Default 10km radius
    @Query('bloodGroup') bloodGroup: string = ""
  ) {
    const donors = await this.getDonors();
    let filteredDonors = donors.data;
    
    // Filter by blood group if provided
    if (bloodGroup) {
      filteredDonors = filteredDonors.filter(d => d.bloodGroup === bloodGroup);
    }
    
    filteredDonors = filteredDonors.map(donor => {
      // Calculate dummy distance based on coordinates
      // In a real implementation, you would use haversine formula
      const [donorLat, donorLng] = donor.coordinates.split(',').map(Number);
      const distance = this.calculateDistance(
        Number(latitude),
        Number(longitude),
        donorLat,
        donorLng
      );

      return {
        ...donor,
        distance: distance.toFixed(2) // Distance in km
      };
    })
      .filter(donor => Number(donor.distance) <= Number(radius))
      .sort((a, b) => Number(a.distance) - Number(b.distance));

    return {
      status: 'success',
      data: filteredDonors,
      count: filteredDonors.length
    };
  }

  @Public()
  @Get('donors/:id')
  async getDonorById(@Param('id') id: string) {
    const donors = await this.getDonors();
    const donor = donors.data.find(d => d.id === id);

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
    const distance = R * c; // Distance in km
    return distance;
  }

  private deg2rad(deg: number): number {
    return deg * (Math.PI / 180);
  }
}
