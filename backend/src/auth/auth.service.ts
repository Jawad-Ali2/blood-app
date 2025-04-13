import {
  BadRequestException,
  Injectable,
  InternalServerErrorException,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import { Tokens } from './types/auth.types';
import { User } from 'src/user/entities/user.entity';
import { jwtConstants } from 'src/constants';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    private readonly jwtService: JwtService,
  ) { }

  async signUp(
    username: string,
    phone: string,
    email: string,
    cnic: string,
    city: string,
    coordinates: string,
    dob: Date,
    password: string,
    confirmPassword: string,
  ): Promise<Tokens> {

    if (password !== confirmPassword) throw new BadRequestException();

    try {
      console.log(dob, typeof dob);
      const existingUser = await this.userRepository.findOne({
        where: [{ email }, { cnic }],
      });
      if (existingUser) {
        if (existingUser.email === email) {
          throw new BadRequestException('Email already exists');
        }
        if (existingUser.cnic === cnic) {
          throw new BadRequestException('Cnic already exists');
        }
      }

      // convert dob to Date type

      const user = this.userRepository.create({
        username,
        phone,
        email,
        cnic,
        city,
        coordinates,
        dateOfBirth: dob,
        password
      });


      await this.userRepository.save(user);

      const tokens = await this.generateTokens(
        user.id,
        user.username,
        user.email,
        user.role,
        user.cnic,
      );
      return tokens;
    } catch (err) {
      throw err;
    }
  }

  async signIn(email: string, userPassword: string) {
    const user = await this.userRepository.findOne({
      where: {
        email,
      },
    });

    if (!user) throw new NotFoundException('User not found');

    const passwordMatched = await user.isMatch(userPassword);

    if (!passwordMatched) throw new NotFoundException('Wrong credentials.');

    const tokens = await this.generateTokens(
      user.id,
      user.username,
      user.email,
      user.role,
      user.cnic,
    );

    user.refreshToken = tokens.refreshToken;

    await this.userRepository.save(user);

    const modifiedUser = {
      id: user.id,
      username: user.username,
      email: user.email,
      role: user.role,
    };

    return { tokens, modifiedUser };
  }

  async guestSignIn() {
    const guestUser = {
      id: 'guest_' + Math.random().toString(36).substring(2, 9),
      role: 'guest',
    };

    const payload = { sub: guestUser.id, role: guestUser.role };
    const token = await this.jwtService.signAsync(payload, { expiresIn: '1h' });

    return token;
  }

  async refreshAccessToken(refreshToken: string) {
    const decodedToken = await this.jwtService.verifyAsync(refreshToken, {
      secret: jwtConstants.secret,
    });

    const user = await this.userRepository.findOneBy({ id: decodedToken.sub });

    if (!user) throw new NotFoundException('User not found or invalid token');

    if (refreshToken !== user.refreshToken)
      throw new UnauthorizedException('Invalid refresh token');

    const tokens = await this.generateTokens(
      user.id,
      user.username,
      user.email,
      user.role,
      user.cnic,
    );

    user.refreshToken = tokens.refreshToken;

    await this.userRepository.save(user);

    return tokens;
  }

  async generateTokens(
    userId: string,
    username: string,
    email: string,
    role: string[],
    cnic: string
  ): Promise<Tokens> {
    const payload = {
      sub: userId,
      username,
      email,
      cnic,
      role,
    };

    const [accessToken, refreshToken]: [string, string] = await Promise.all([
      this.jwtService.signAsync(payload, {
        secret: jwtConstants.secret,
        expiresIn: '1h',
      }),
      this.jwtService.signAsync(payload, {
        secret: jwtConstants.secret,
        expiresIn: '7d',
      }),
    ]);

    return {
      accessToken,
      refreshToken,
    };
  }
}
