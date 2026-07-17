import 'package:hive/hive.dart';

part 'cat_state.g.dart';

@HiveType(typeId: 0)
class CatState extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int bondLevel; // 0-100

  @HiveField(3)
  final List<String> accessoriesUnlocked;

  @HiveField(4)
  final String? equippedAccessory;

  @HiveField(5)
  final DateTime? lastInteractionDate;

  @HiveField(6)
  final int currentStreak;

  @HiveField(7)
  final int longestStreak;

  @HiveField(8)
  final DateTime adoptedDate;

  CatState({
    required this.id,
    this.name = 'Whisker',
    this.bondLevel = 0,
    List<String>? accessoriesUnlocked,
    this.equippedAccessory,
    this.lastInteractionDate,
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.adoptedDate,
  }) : accessoriesUnlocked = accessoriesUnlocked ?? const [];

  // computed moodToday (sleepy, content, playful, affectionate — computed, not stored long-term)
  String get moodToday {
    final now = DateTime.now();
    final daySeed = now.year + now.month + now.day + id.hashCode;
    final moods = ['sleepy', 'content', 'playful', 'affectionate'];
    return moods[daySeed % moods.length];
  }

  CatState copyWith({
    String? id,
    String? name,
    int? bondLevel,
    List<String>? accessoriesUnlocked,
    String? equippedAccessory,
    DateTime? lastInteractionDate,
    int? currentStreak,
    int? longestStreak,
    DateTime? adoptedDate,
  }) {
    return CatState(
      id: id ?? this.id,
      name: name ?? this.name,
      bondLevel: bondLevel ?? this.bondLevel,
      accessoriesUnlocked: accessoriesUnlocked ?? this.accessoriesUnlocked,
      equippedAccessory: equippedAccessory ?? this.equippedAccessory,
      lastInteractionDate: lastInteractionDate ?? this.lastInteractionDate,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      adoptedDate: adoptedDate ?? this.adoptedDate,
    );
  }
}
