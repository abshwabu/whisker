import 'package:flutter/material.dart';

class Accessory {
  final String id;
  final String displayName;
  final int bondLevelRequired;
  final IconData previewIcon;
  final String description;

  const Accessory({
    required this.id,
    required this.displayName,
    required this.bondLevelRequired,
    required this.previewIcon,
    required this.description,
  });
}

final List<Accessory> accessoriesList = [
  const Accessory(
    id: 'Red Collar',
    displayName: 'Red Collar',
    bondLevelRequired: 10,
    previewIcon: Icons.circle_notifications,
    description: 'A simple, classic red collar for a stylish cat.',
  ),
  const Accessory(
    id: 'Yellow Bell',
    displayName: 'Yellow Bell',
    bondLevelRequired: 25,
    previewIcon: Icons.notifications_active,
    description: 'Hear Whisker jingle as they stroll around!',
  ),
  const Accessory(
    id: 'Pink Bow',
    displayName: 'Pink Bow',
    bondLevelRequired: 50,
    previewIcon: Icons.bookmark,
    description: 'A charming pink bow to wear on their ear.',
  ),
  const Accessory(
    id: 'Wizard Hat',
    displayName: 'Wizard Hat',
    bondLevelRequired: 75,
    previewIcon: Icons.brightness_3,
    description: 'Magical pointed hat decorated with golden stars.',
  ),
  const Accessory(
    id: 'Crown',
    displayName: 'Royal Crown',
    bondLevelRequired: 100,
    previewIcon: Icons.workspace_premium,
    description: 'The ultimate accessory for the true ruler of the house.',
  ),
];
