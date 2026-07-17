import 'package:hive/hive.dart';

part 'diary_entry.g.dart';

@HiveType(typeId: 3)
class DiaryEntry extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final String? imagePath;

  @HiveField(3)
  final bool authorIsHer;

  DiaryEntry({
    required this.date,
    required this.text,
    this.imagePath,
    required this.authorIsHer,
  });

  DiaryEntry copyWith({
    DateTime? date,
    String? text,
    String? imagePath,
    bool? authorIsHer,
  }) {
    return DiaryEntry(
      date: date ?? this.date,
      text: text ?? this.text,
      imagePath: imagePath ?? this.imagePath,
      authorIsHer: authorIsHer ?? this.authorIsHer,
    );
  }
}
