
type PostListingDTO = {
    location: string;
    groupRequired: string;
    // proof: string;
    bagsRequired: number;
    requiredTill: Date,
    pickAndDrop: boolean;
    willPay: boolean;
    userId: string;
}