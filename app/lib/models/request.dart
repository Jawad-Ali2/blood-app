class Request {
  final String location;
  final String groupRequired;
  final int bagsRequired;
  final DateTime requiredTill;
  final bool pickAndDrop;
  final bool willPay;
  final int userCredibility;
  final String userContact;

  // final double distance; // Distance in km

  Request({
    required this.location,
    required this.groupRequired,
    required this.bagsRequired,
    required this.requiredTill,
    required this.pickAndDrop,
    required this.willPay,
    required this.userCredibility,
    required this.userContact,
    // required this.distance,
  });

  // Factory method to parse JSON response
  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      location: json['location'],
      groupRequired: json['groupRequired'],
      bagsRequired: json['bagsRequired'],
      requiredTill: DateTime.parse(json['requiredTill']),
      pickAndDrop: json['pickAndDrop'],
      willPay: json['willPay'],
      userCredibility: json['user']['userCredibility'],
      userContact: json['user']['userContact'],
      // distance: json['distance'].toDouble(),
    );
  }
}

// Dummy Data
List<Request> posts = [
  Request(
    location: "Downtown Hospital",
    groupRequired: "O+",
    bagsRequired: 2,
    requiredTill: DateTime.now().add(Duration(days: 2)),
    pickAndDrop: true,
    willPay: false,
    userCredibility: 8,
    userContact: "123-456-789",
    // distance: 2.3,
  ),
  Request(
    location: "City Clinic",
    groupRequired: "A-",
    bagsRequired: 1,
    requiredTill: DateTime.now().add(Duration(days: 1)),
    pickAndDrop: false,
    willPay: true,
    userCredibility: 9,
    userContact: "987-654-321",
    // distance: 1.5,
  ),
];
