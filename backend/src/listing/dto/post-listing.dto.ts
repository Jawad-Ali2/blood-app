import { IsBoolean, IsDateString, IsNotEmpty, IsNumber, IsOptional, IsString } from 'class-validator';

export class PostListingDTO {
  @IsString()
  @IsNotEmpty()
  groupRequired: string;

  @IsNumber()
  @IsNotEmpty()
  bagsRequired: number;

  @IsDateString()
  @IsNotEmpty()
  requiredTill: string;

  @IsBoolean()
  pickAndDrop: boolean;

  @IsBoolean()
  @IsOptional()
  willPay?: boolean;

  @IsString()
  @IsOptional()
  hospitalName?: string;

  @IsString()
  @IsOptional()
  address?: string;

  @IsBoolean()
  @IsOptional()
  isEmergency?: boolean;

  @IsString()
  @IsOptional()
  notes?: string;

  @IsString()
  @IsNotEmpty()
  userId: string;
}
