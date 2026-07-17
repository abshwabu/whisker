import 'package:whisker/models/hidden_message.dart';

final List<HiddenMessage> hiddenMessagesSeed = [
  HiddenMessage(
    bondLevelRequired: 10,
    text: "PUT_YOUR_MESSAGE_HERE_10 - You took your first steps in caring for Whisker! Every small gesture makes a difference. 💕",
  ),
  AccessoryMessage(
    bondLevelRequired: 25,
    text: "PUT_YOUR_MESSAGE_HERE_25 - Whisker is starting to feel very comfortable around you. They love when you brush their soft fur! 🐾",
  ),
  AccessoryMessage(
    bondLevelRequired: 50,
    text: "PUT_YOUR_MESSAGE_HERE_50 - Halfway there! Whisker trusts you completely now, and looks forward to your daily cuddles. 🥰",
  ),
  AccessoryMessage(
    bondLevelRequired: 75,
    text: "PUT_YOUR_MESSAGE_HERE_75 - Whisker feels like you are a true companion. A deep bond has blossomed between you two! 🌸",
  ),
  AccessoryMessage(
    bondLevelRequired: 100,
    text: "PUT_YOUR_MESSAGE_HERE_100 - Maximum Bond! Whisker has found their forever home and loves you with all their heart. 👑✨",
  ),
];

// Using standard HiddenMessage constructor for consistency
class AccessoryMessage extends HiddenMessage {
  AccessoryMessage({
    required super.bondLevelRequired,
    required super.text,
    super.imagePath,
  });
}
