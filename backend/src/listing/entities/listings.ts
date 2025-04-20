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
    // Create only 4 status values: active, completed, cancelled, expired
    // active - Listing is currently active and accepting donations
    // completed - Listing has been completed and no more donations are needed
    // cancelled - Listing has been cancelled and no donations are needed
    // expired - Listing has expired and no donations are needed
    // Default value is active
    @Column({ default: 'active' })
    status: string;

    // Will contain UserId
    @ManyToOne(() => User, (user) => user.listings)
    @JoinColumn({ name: "userId" })
    user: User;

    // Column containing id of the user which accepted the listing
    @ManyToOne(() => User, (user) => user.acceptedListings, { nullable: true })
    @JoinColumn({ name: "acceptedBy" })
    acceptedBy: User;

    // Column containing id of the user which fulfilled the listing
    @ManyToOne(() => User, (user) => user.fulfilledListings, { nullable: true })
    @JoinColumn({ name: "fulfilledBy" })
    fulfilledBy: User;


    @CreateDateColumn({ type: 'timestamp' })
    createdAt: Date;

    @CreateDateColumn({ type: 'timestamp' })
    updatedAt: Date;
}
