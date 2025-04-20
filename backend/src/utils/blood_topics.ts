const bloodGroups = [
  'A+',
  'A-',
  'B+',
  'B-',
  'O+',
  'O-',
  'AB+',
  'AB-',
];

export const bloodGroupToTopic = (bg: string) => bg.replaceAll('+', 'Plus').replaceAll('-', 'Minus');
