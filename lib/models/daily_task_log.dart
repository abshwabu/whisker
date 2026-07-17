import 'package:hive/hive.dart';

part 'daily_task_log.g.dart';

@HiveType(typeId: 1)
class DailyTaskLog extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final bool feedDone;

  @HiveField(2)
  final bool playDone;

  @HiveField(3)
  final bool brushDone;

  @HiveField(4)
  final bool cuddleDone;

  @HiveField(5)
  final String? noteUnlocked;

  DailyTaskLog({
    required this.date,
    this.feedDone = false,
    this.playDone = false,
    this.brushDone = false,
    this.cuddleDone = false,
    this.noteUnlocked,
  });

  DailyTaskLog copyWith({
    DateTime? date,
    bool? feedDone,
    bool? playDone,
    bool? brushDone,
    bool? cuddleDone,
    String? noteUnlocked,
  }) {
    return DailyTaskLog(
      date: date ?? this.date,
      feedDone: feedDone ?? this.feedDone,
      playDone: playDone ?? this.playDone,
      brushDone: brushDone ?? this.brushDone,
      cuddleDone: cuddleDone ?? this.cuddleDone,
      noteUnlocked: noteUnlocked ?? this.noteUnlocked,
    );
  }
}
