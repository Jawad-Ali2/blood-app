import {
  BeforeInsert,
  BeforeUpdate,
  Column,
  Entity,
  PrimaryColumn,
  PrimaryGeneratedColumn,
} from 'typeorm';
import * as bcrypt from 'bcrypt';

@Entity()
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ nullable: true })
  password: string;

  @Column()
  username: string;

  @Column({ unique: true, nullable: true })
  email: string;

  @Column('simple-json', { default: JSON.stringify(['recipient']) })
  role: string[];

  @Column({ nullable: true })
  refreshToken: string;

  @Column({ unique: true })
  cnic: string;

  @Column({ nullable: true })
  bloodGroup: string;

  @Column()
  phone: string;

  @Column({ nullable: true })
  age: number;

  @Column()
  isVerified: boolean;

  @Column()
  isDonor: boolean;

  @Column()
  lastDonationDate: Date;

  @Column()
  credibilityPoints: number;

  @Column()
  city: string;

//   @Column()
//   country: string;

  @BeforeInsert()
  async hashPassword() {
    this.password = await bcrypt.hash(this.password, 10);
  }

  async isMatch(enteredPassword: string): Promise<boolean> {
    if (enteredPassword) {
      return await bcrypt.compare(enteredPassword, this.password);
    }
    return false;
  }
}
