import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppService } from './app.service';
import { ConfigModule } from '@nestjs/config';
import { UserModule } from './user/user.module';
import { AuthModule } from './auth/auth.module';
import { ListingModule } from './listing/listing.module';
import { FcmModule } from './fcm/fcm.module';
import { FirebaseModule } from './firebase/firebase.module';

@Module({
  imports: [
    ConfigModule.forRoot(),
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DATABASE_HOST,
      // port: 5432, // Default PostgreSQL port
      password: process.env.DATABASE_PASSWORD,
      username: process.env.DATABASE_USER,
      // entities: [User],
      autoLoadEntities: true,
      database: process.env.DATABASE_NAME,
      synchronize: true,
      logging: ['error', 'schema', 'info'],
      ssl: {
        rejectUnauthorized: false,
      },
    }),
    UserModule,
    AuthModule,
    ListingModule,
    FcmModule,
    // FirebaseModule
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
