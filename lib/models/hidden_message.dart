import 'package:hive/hive.dart';

part 'hidden_message.g.dart';

@HiveType(typeId: 2)
class HiddenMessage extends HiveObject {
  @HiveField(0)
  final int bondLevelRequired;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final String? imagePath;

  HiddenMessage({
    required this.bondLevelRequired,
    required this.text,
    this.imagePath,
  });

  HiddenMessage copyWith({
    int? bondLevelRequired,
    String? text,
    String? imagePath,
  }) {
    return HiddenMessage(
      bondLevelRequired: bondLevelRequired ?? this.bondLevelRequired,
      text: text ?? this.text,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
