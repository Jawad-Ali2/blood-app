
type PostListingDTO = {
    location: { latitude: number; longitude: number };
    groupRequired: string;
    // proof: string;
    bagsRequired: number;
    requiredTill: Date,
    pickAndDrop: boolean;
    willPay: boolean;
    userId: string;
}