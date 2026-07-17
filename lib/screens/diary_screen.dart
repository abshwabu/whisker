import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:whisker/models/diary_entry.dart';
import 'package:whisker/models/daily_task_log.dart';
import 'package:whisker/providers/cat_provider.dart';

class DiaryScreen extends ConsumerStatefulWidget {
  const DiaryScreen({super.key});

  @override
  ConsumerState<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends ConsumerState<DiaryScreen> {
  final TextEditingController _textController = TextEditingController();
  String? _selectedSticker;

  final List<String> _stickers = [
    '🐾 Pawprint',
    '💖 Hearts',
    '😺 Happy Cat',
    '💤 Sleepy',
    '🧶 Playing Yarn',
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showAddEntrySheet(BuildContext context) {
    _textController.clear();
    _selectedSticker = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFF9F8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'New Journal Entry',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A3E3D),
                ),
              ),
              const SizedBox(height: 16),

              // Journal entry input
              TextField(
                controller: _textController,
                maxLines: 3,
                style: const TextStyle(color: Color(0xFF4A3E3D)),
                decoration: InputDecoration(
                  hintText: 'How was your day with Whisker? ...',
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.8),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFFFB5A7)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sticker selector for mock photo
              const Text(
                'Add a Sticker (Stickers & Mock Photos)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A3E3D),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _stickers.length,
                  itemBuilder: (ctx, index) {
                    final sticker = _stickers[index];
                    final isSelected = _selectedSticker == sticker;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(sticker),
                        selected: isSelected,
                        selectedColor: const Color(0xFFFFB5A7),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF4A3E3D),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (val) {
                          setSheetState(() {
                            _selectedSticker = val ? sticker : null;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB5A7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    if (_textController.text.trim().isNotEmpty) {
                      final newEntry = DiaryEntry(
                        date: DateTime.now(),
                        text: _textController.text.trim(),
                        imagePath: _selectedSticker, // Custom sticker serves as mock imagePath/sticker
                        authorIsHer: true,
                      );
                      Hive.box<DiaryEntry>('diaryBox').add(newEntry);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text(
                    'Save to Diary',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catState = ref.watch(catProvider);

    // Calculate past 10 days for calendar
    final today = DateTime.now();
    final List<DateTime> pastDays = List.generate(10, (i) {
      return today.subtract(Duration(days: 9 - i));
    });

    final taskLogBox = Hive.box<DailyTaskLog>('dailyTaskLogBox');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Whisker\'s Diary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFF9F8),
              Color(0xFFFCD5CE),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Top section: Stats & Calendar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                children: [
                  // Streak Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard('Current Streak', '🔥 ${catState.currentStreak} Days'),
                      _buildStatCard('Longest Streak', '🏆 ${catState.longestStreak} Days'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Horizontal Calendar History
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Activity History',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A3E3D),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: pastDays.map((date) {
                        final key = _formatDateKey(date);
                        final log = taskLogBox.get(key);
                        final isCompleted = log != null &&
                            (log.feedDone || log.playDone || log.brushDone || log.cuddleDone);

                        final isToday = date.day == today.day &&
                            date.month == today.month &&
                            date.year == today.year;

                        return Column(
                          children: [
                            Text(
                              DateFormat('E').format(date).substring(0, 1),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isToday ? const Color(0xFFFFB5A7) : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted
                                    ? const Color(0xFFFFB5A7)
                                    : Colors.white.withValues(alpha: 0.8),
                                border: Border.all(
                                  color: isCompleted
                                      ? const Color(0xFFFFB5A7)
                                      : Colors.grey[300]!,
                                  width: isToday ? 2.0 : 1.0,
                                ),
                              ),
                              child: isCompleted
                                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              date.day.toString(),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFFCD5CE)),

            // Journal Timeline list
            Expanded(
              child: ValueListenableBuilder<Box<DiaryEntry>>(
                valueListenable: Hive.box<DiaryEntry>('diaryBox').listenable(),
                builder: (context, box, _) {
                  final entries = box.values.toList().reversed.toList();

                  if (entries.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_stories, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Your diary is empty.',
                            style: TextStyle(color: Colors.grey[600], fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Complete daily tasks or add a custom log!',
                            style: TextStyle(color: Colors.grey[500], fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return _buildDiaryCard(entry);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFB5A7),
        shape: const CircleBorder(),
        onPressed: () => _showAddEntrySheet(context),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A3E3D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryCard(DiaryEntry entry) {
    final dateStr = DateFormat('MMMM d, y h:mm a').format(entry.date);

    return Card(
      elevation: 0,
      color: entry.authorIsHer
          ? Colors.white.withValues(alpha: 0.8)
          : const Color(0xFFFFF2EE).withValues(alpha: 0.8),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: entry.authorIsHer
            ? BorderSide.none
            : const BorderSide(color: Color(0xFFFFD7CC), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge & Date Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: entry.authorIsHer ? const Color(0xFFFFE5E0) : const Color(0xFFFFD5CC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    entry.authorIsHer ? 'My Journal 📝' : 'Whisker\'s Note 💌',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A3E3D),
                    ),
                  ),
                ),
                Text(
                  dateStr,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Message text
            Text(
              entry.text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4A3E3D),
                height: 1.4,
              ),
            ),

            // Optional sticker/image display
            if (entry.imagePath != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 14, color: Color(0xFFFFB5A7)),
                    const SizedBox(width: 6),
                    Text(
                      entry.imagePath!,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4A3E3D)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
