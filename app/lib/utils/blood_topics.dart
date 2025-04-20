const List<String> bloodGroups = [
  'A+',
  'A-',
  'B+',
  'B-',
  'AB+',
  'AB-',
  'O+',
  'O-',
];

String bloodGroupToTopic(String bg) => bg.replaceAll('+', 'Plus').replaceAll('-', 'Minus');
