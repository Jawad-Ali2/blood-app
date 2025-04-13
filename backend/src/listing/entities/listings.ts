import { User } from "src/user/entities/user.entity";
import { Column, CreateDateColumn, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from "typeorm";

@Entity()
export class Listing {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column()
    groupRequired: string;

    @Column()
    bagsRequired: number;

    @Column()
    requiredTill: Date;

    @Column()
    pickAndDrop: boolean;

    @Column({ nullable: true })
    willPay: boolean;

    // Hospital or medical facility name
    @Column({ nullable: true })
    hospitalName: string;

    // Address in text format for readability
    @Column({ nullable: true })
    address: string;

    // For emergency cases
    @Column({ default: false })
    isEmergency: boolean;

    // Notes or special instructions (can include purpose and other details)
    @Column({ type: 'text', nullable: true })
    notes: string;

    // Status field for tracking listing state
    @Column({ default: 'active' })
    status: string;

    // Will contain UserId
    @ManyToOne(() => User, (user) => user.listings)
    @JoinColumn({ name: "userId" })
    user: User;

    @CreateDateColumn({ type: 'timestamp' })
    createdAt: Date;

    @CreateDateColumn({ type: 'timestamp' })
    updatedAt: Date;
}
