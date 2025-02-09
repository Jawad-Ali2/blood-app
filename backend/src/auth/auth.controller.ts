import { Controller, Post, Body, Get, Res, Req } from '@nestjs/common';
import { Public } from 'src/common/decorators/public.decorator';
import { Roles } from 'src/common/decorators/roles.decorator';
import { Role } from 'src/constants';
import { Tokens } from './types/auth.types';
import { Request, Response } from 'express';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) { }

  @Public()
  @Post('register')
  async register(
    @Body('username') username: string,
    @Body('phone') phone: string,
    @Body('email') email: string,
    @Body('cnic') cnic: string,
    @Body('city') city: string,
    @Body('age') age: number,
    @Body('password') password: string,
    @Body('confirmPassword') confirmPassword: string,
    @Res() res: Response,
  ) {

    console.log(username,
      phone,
      email,
      cnic,
      city,
      age,
      password,
      confirmPassword);

    // Cnic should be 13 charaters long
    const tokens: Tokens = await this.authService.signUp(
      username,
      phone,
      email,
      cnic,
      city,
      age,
      password,
      confirmPassword,
    );

    res.cookie('at', tokens.accessToken);
    res.cookie('rt', tokens.refreshToken);

    return res.status(200).json({ message: 'Tokens set in cookies' });
  }

  @Public()
  @Post('login')
  async login(
    @Body('email') email: string,
    @Body('password') password: string,
    @Res() res: Response,
  ) {
    const { tokens, modifiedUser } = await this.authService.signIn(
      email,
      password,
    );

    res.cookie('at', tokens.accessToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: process.env.NODE_ENV === 'production' ? 'none' : 'strict',
    });
    res.cookie('rt', tokens.refreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: process.env.NODE_ENV === 'production' ? 'none' : 'strict',
    });

    return res.status(200).json({
      user: modifiedUser,
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    });
  }

  @Public()
  @Post('guest-login')
  async guestLogin(@Res() res: Response) {
    const accessToken = await this.authService.guestSignIn();

    // Todo: Add options for the cookie
    res.cookie('accessToken', accessToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: process.env.NODE_ENV === 'production' ? 'none' : 'strict',
    });

    return;
  }

  @Public()
  @Post('refresh-token')
  async refreshAccessToken(@Req() req: Request, @Res() res: Response) {
    console.log(req.cookies.rt);
    const refreshToken = req.cookies?.rt || req.body.refreshToken;

    // If a guest user tries to refresh token they immediately gets error and log em out
    if (!refreshToken) return;

    const tokens = await this.authService.refreshAccessToken(refreshToken);

    res.cookie('at', tokens.accessToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: process.env.NODE_ENV === 'production' ? 'none' : 'strict',
    });
    res.cookie('rt', tokens.refreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: process.env.NODE_ENV === 'production' ? 'none' : 'strict',
    });

    return res.status(200).json({
      message: 'Tokens set in cookies',
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    });
  }

  @Get('donor')
  @Roles(Role.DONOR)
  getDonorDashboard() {
    // TODO: We will add form for donor
    return 'Donor Dashboard';
  }

  @Get('receiver')
  @Roles(Role.RECIEVER)
  getReceiverDashboard() {
    // TODO: We will add form for reciever to request blood
    return 'Receiver Dashboard';
  }


  @Get('profile')
  getProfile(@Req() req) {
    return req.user;
  }
}
