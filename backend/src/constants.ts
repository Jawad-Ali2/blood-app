const jwtConstants = {
    secret: "ABC"
}

enum Role {
    DONOR = "donor",
    RECIPIENT = "recipient",
}

enum ListingStatus{
    ACTIVE = "active",
    IN_PROGRESS = "in-progress",
    CANCELED = "canceled",
    FULFILLED = "fulfilled",
}

const bloodTypeCrossMatch: { [key: string]: string[] } = {
    'A+': ['A+', 'A-', 'O+', 'O-'],
    'A-': ['A-', 'O-'],
    'B+': ['B+', 'B-', 'O+', 'O-'],
    'B-': ['B-', 'O-'],
    'AB+': ['AB+', 'AB-', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-'],
    'AB-': ['AB-', 'A-', 'B-', 'O-'],
    'O+': ['O+', 'O-'],
    'O-': ['O-'],
};
export { jwtConstants, Role, ListingStatus, bloodTypeCrossMatch };
