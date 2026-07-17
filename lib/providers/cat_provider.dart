import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive/hive.dart';
import 'package:whisker/models/cat_state.dart';
import 'package:whisker/models/daily_task_log.dart';
import 'package:whisker/models/task_type.dart';

// Provider to manage today's task log
final dailyTaskProvider = StateNotifierProvider<DailyTaskNotifier, DailyTaskLog>((ref) {
  return DailyTaskNotifier();
});

// Provider to manage the cat's state reactively
final catProvider = StateNotifierProvider<CatNotifier, CatState>((ref) {
  return CatNotifier(ref);
});

class DailyTaskNotifier extends StateNotifier<DailyTaskLog> {
  DailyTaskNotifier() : super(_getOrCreateTodayLog());

  static String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static DailyTaskLog _getOrCreateTodayLog() {
    final box = Hive.box<DailyTaskLog>('dailyTaskLogBox');
    final today = DateTime.now();
    final key = _formatDateKey(today);
    var log = box.get(key);
    if (log == null) {
      log = DailyTaskLog(date: today);
      box.put(key, log);
    }
    return log;
  }

  DailyTaskLog markTaskDone(TaskType type) {
    DailyTaskLog updated;
    switch (type) {
      case TaskType.feed:
        updated = state.copyWith(feedDone: true);
        break;
      case TaskType.play:
        updated = state.copyWith(playDone: true);
        break;
      case TaskType.brush:
        updated = state.copyWith(brushDone: true);
        break;
      case TaskType.cuddle:
        updated = state.copyWith(cuddleDone: true);
        break;
    }
    final box = Hive.box<DailyTaskLog>('dailyTaskLogBox');
    final key = _formatDateKey(state.date);
    box.put(key, updated);
    state = updated;
    return updated;
  }
}

class CatNotifier extends StateNotifier<CatState> {
  final Ref ref;

  CatNotifier(this.ref) : super(_loadInitialState()) {
    checkForMissedDay();
  }

  static CatState _loadInitialState() {
    final box = Hive.box<CatState>('catStateBox');
    return box.get('default_cat') ?? CatState(
      id: 'default_cat',
      name: 'Whisker',
      bondLevel: 0,
      adoptedDate: DateTime.now(),
    );
  }

  static String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool _isYesterdayActive() {
    final box = Hive.box<DailyTaskLog>('dailyTaskLogBox');
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final yesterday = todayDate.subtract(const Duration(days: 1));
    final key = _formatDateKey(yesterday);
    final log = box.get(key);
    if (log == null) return false;
    return log.feedDone || log.playDone || log.brushDone || log.cuddleDone;
  }

  Future<void> completeTask(TaskType type) async {
    final todayLog = ref.read(dailyTaskProvider);
    
    // Check if the task is already done today
    bool alreadyDone = false;
    switch (type) {
      case TaskType.feed:
        alreadyDone = todayLog.feedDone;
        break;
      case TaskType.play:
        alreadyDone = todayLog.playDone;
        break;
      case TaskType.brush:
        alreadyDone = todayLog.brushDone;
        break;
      case TaskType.cuddle:
        alreadyDone = todayLog.cuddleDone;
        break;
    }
    
    if (alreadyDone) return;

    // Mark task done in DailyTaskLog (this updates dailyTaskProvider state/Hive)
    final updatedLog = ref.read(dailyTaskProvider.notifier).markTaskDone(type);

    // Increase bondLevel by +2, capped at 100
    int newBondLevel = (state.bondLevel + 2).clamp(0, 100);

    // Streak Logic
    int newCurrentStreak = state.currentStreak;
    int newLongestStreak = state.longestStreak;
    final now = DateTime.now();

    final totalDoneToday = (updatedLog.feedDone ? 1 : 0) +
                           (updatedLog.playDone ? 1 : 0) +
                           (updatedLog.brushDone ? 1 : 0) +
                           (updatedLog.cuddleDone ? 1 : 0);

    if (totalDoneToday == 1) {
      // First task completed today! Check if yesterday was active
      if (state.lastInteractionDate == null) {
        newCurrentStreak = 1;
      } else {
        if (_isYesterdayActive()) {
          newCurrentStreak += 1;
        } else {
          newCurrentStreak = 1;
        }
      }
      if (newCurrentStreak > newLongestStreak) {
        newLongestStreak = newCurrentStreak;
      }
    }

    // Check accessory unlock thresholds: 10/25/50/75/100
    final newlyUnlockedAccessories = List<String>.from(state.accessoriesUnlocked);
    final thresholds = {
      10: 'Red Collar',
      25: 'Yellow Bell',
      50: 'Pink Bow',
      75: 'Wizard Hat',
      100: 'Crown'
    };

    thresholds.forEach((threshold, accessory) {
      if (newBondLevel >= threshold && !newlyUnlockedAccessories.contains(accessory)) {
        newlyUnlockedAccessories.add(accessory);
      }
    });

    final updatedCatState = state.copyWith(
      bondLevel: newBondLevel,
      accessoriesUnlocked: newlyUnlockedAccessories,
      lastInteractionDate: now,
      currentStreak: newCurrentStreak,
      longestStreak: newLongestStreak,
    );

    // Persist CatState to Hive
    final box = Hive.box<CatState>('catStateBox');
    await box.put(state.id, updatedCatState);

    // Update state to trigger listeners
    state = updatedCatState;
  }

  bool allTasksDoneToday() {
    final todayLog = ref.read(dailyTaskProvider);
    return todayLog.feedDone && todayLog.playDone && todayLog.brushDone && todayLog.cuddleDone;
  }

  void checkForMissedDay() {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    
    // If we already ran the decay check today, return to prevent multiple decay deductions
    if (state.lastDecayCheckDate != null) {
      final lastCheck = DateTime(
        state.lastDecayCheckDate!.year,
        state.lastDecayCheckDate!.month,
        state.lastDecayCheckDate!.day,
      );
      if (lastCheck.isAtSameMomentAs(todayDate)) {
        return;
      }
    }

    final lastInteraction = state.lastInteractionDate;
    int decay = 0;
    if (lastInteraction != null) {
      final lastIntDate = DateTime(
        lastInteraction.year,
        lastInteraction.month,
        lastInteraction.day,
      );
      final daysDiff = todayDate.difference(lastIntDate).inDays;
      if (daysDiff > 1) {
        decay = daysDiff - 1; // -1 per missed day beyond the first
      }
    }

    final newBondLevel = (state.bondLevel - decay).clamp(0, 100);
    
    final updatedCatState = state.copyWith(
      bondLevel: newBondLevel,
      lastDecayCheckDate: now,
    );

    final box = Hive.box<CatState>('catStateBox');
    box.put(state.id, updatedCatState);
    state = updatedCatState;
  }

  Future<void> equipAccessory(String? id) async {
    if (id != null && !state.accessoriesUnlocked.contains(id)) {
      // Cannot equip if not unlocked
      return;
    }
    final updatedCatState = state.copyWith(equippedAccessory: id);
    final box = Hive.box<CatState>('catStateBox');
    await box.put(state.id, updatedCatState);
    state = updatedCatState;
  }

  Future<void> updateName(String newName) async {
    if (newName.trim().isEmpty) return;
    final updatedCatState = state.copyWith(name: newName.trim());
    final box = Hive.box<CatState>('catStateBox');
    await box.put(state.id, updatedCatState);
    state = updatedCatState;
  }
}
