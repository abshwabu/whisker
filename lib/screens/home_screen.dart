import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whisker/models/task_type.dart';
import 'package:whisker/providers/cat_provider.dart';
import 'package:whisker/widgets/cat_painter.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    // Micro-animation for gentle floating of the cat
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  void _showRenameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFF9F8),
        title: const Text(
          'Rename Your Cat',
          style: TextStyle(color: Color(0xFF4A3E3D), fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter new name...',
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFFFB5A7)),
            ),
          ),
          style: const TextStyle(color: Color(0xFF4A3E3D)),
          maxLength: 15,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(catProvider.notifier).updateName(controller.text.trim());
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAccessoryDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFF9F8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, child) {
            final cat = ref.watch(catProvider);
            final notifier = ref.read(catProvider.notifier);

            final allAccessories = [
              {'id': 'Red Collar', 'unlock': 10, 'icon': Icons.circle_notifications},
              {'id': 'Yellow Bell', 'unlock': 25, 'icon': Icons.notifications_active},
              {'id': 'Pink Bow', 'unlock': 50, 'icon': Icons.bookmark},
              {'id': 'Wizard Hat', 'unlock': 75, 'icon': Icons.brightness_3},
              {'id': 'Crown', 'unlock': 100, 'icon': Icons.workspace_premium},
            ];

            return SizedBox(
              height: 400,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Accessory Wardrobe',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A3E3D),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: allAccessories.length,
                        itemBuilder: (context, index) {
                          final accessory = allAccessories[index];
                          final id = accessory['id'] as String;
                          final unlockLevel = accessory['unlock'] as int;
                          final icon = accessory['icon'] as IconData;

                          final isUnlocked = cat.accessoriesUnlocked.contains(id) || cat.bondLevel >= unlockLevel;
                          final isEquipped = cat.equippedAccessory == id;

                          return ListTile(
                            leading: Icon(
                              icon,
                              color: isUnlocked ? const Color(0xFFFFB5A7) : Colors.grey,
                              size: 28,
                            ),
                            title: Text(
                              id,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isUnlocked ? const Color(0xFF4A3E3D) : Colors.grey[600],
                              ),
                            ),
                            subtitle: isUnlocked
                                ? const Text('Unlocked!', style: TextStyle(color: Colors.green, fontSize: 12))
                                : Text('Unlocks at Bond Level $unlockLevel', style: const TextStyle(fontSize: 12)),
                            trailing: isUnlocked
                                ? ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isEquipped ? const Color(0xFFFCD5CE) : const Color(0xFFFFB5A7),
                                    ),
                                    onPressed: () {
                                      if (isEquipped) {
                                        notifier.equipAccessory(null);
                                      } else {
                                        notifier.equipAccessory(id);
                                      }
                                    },
                                    child: Text(isEquipped ? 'Unequip' : 'Equip'),
                                  )
                                : const Icon(Icons.lock, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final catState = ref.watch(catProvider);
    final taskLog = ref.watch(dailyTaskProvider);
    final notifier = ref.read(catProvider.notifier);

    final bool allDone = notifier.allTasksDoneToday();

    // Map moods to descriptions
    String moodDesc = 'sleepy';
    String moodEmoji = '💤';
    switch (catState.moodToday) {
      case 'sleepy':
        moodDesc = 'Feeling sleepy...';
        moodEmoji = '💤';
        break;
      case 'content':
        moodDesc = 'Feeling content';
        moodEmoji = '😺';
        break;
      case 'playful':
        moodDesc = 'Ready to play!';
        moodEmoji = '🧸';
        break;
      case 'affectionate':
        moodDesc = 'Loves you so much!';
        moodEmoji = '💖';
        break;
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFF9F8),
              Color(0xFFFCD5CE),
              Color(0xFFFFB5A7),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // Top Bar: Rename button & Closet Hanger
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_note, color: Color(0xFF4A3E3D), size: 28),
                                onPressed: () => _showRenameDialog(context, catState.name),
                                tooltip: 'Rename Cat',
                              ),
                              IconButton(
                                icon: const Icon(Icons.checkroom, color: Color(0xFF4A3E3D), size: 28),
                                onPressed: () => _showAccessoryDrawer(context),
                                tooltip: 'Accessories Wardrobe',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Title Header
                        Text(
                          catState.name,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A3E3D),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Mood Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$moodEmoji $moodDesc',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A3E3D),
                            ),
                          ),
                        ),
                        const Spacer(),

                        // Floating Interactive Cat
                        AnimatedBuilder(
                          animation: _floatController,
                          builder: (context, child) {
                            final offset = sin(_floatController.value * pi * 2) * 8.0;
                            return Transform.translate(
                              offset: Offset(0, offset),
                              child: child,
                            );
                          },
                          child: CatWidget(
                            mood: catState.moodToday,
                            bondLevel: catState.bondLevel,
                            equippedAccessory: catState.equippedAccessory,
                          ),
                        ),

                        const Spacer(),

                        // Streak & Bond Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Card(
                            elevation: 0,
                            color: Colors.white.withValues(alpha: 0.7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  // Streak badge
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        '🔥 ',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      Text(
                                        '${catState.currentStreak} day streak',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF4A3E3D),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Bond Progress text
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Closeness',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF4A3E3D),
                                        ),
                                      ),
                                      Text(
                                        '${catState.bondLevel}%',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF4A3E3D),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Rounded Progress Bar
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: catState.bondLevel / 100.0,
                                      minHeight: 12,
                                      backgroundColor: Colors.white.withValues(alpha: 0.5),
                                      valueColor: const AlwaysStoppedAnimation<Color>(
                                        Color(0xFFFFB5A7),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Celebration banner (show if all tasks complete)
                        if (allDone)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF9F8).withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFFFB5A7), width: 1),
                              ),
                              child: Text(
                                '${catState.name} had the best day with you today 💕',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A3E3D),
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Bottom Task buttons
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.4),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildTaskButton(
                                label: 'Feed',
                                icon: Icons.restaurant,
                                isDone: taskLog.feedDone,
                                onTap: () => notifier.completeTask(TaskType.feed),
                              ),
                              _buildTaskButton(
                                label: 'Play',
                                icon: Icons.sports_esports,
                                isDone: taskLog.playDone,
                                onTap: () => notifier.completeTask(TaskType.play),
                              ),
                              _buildTaskButton(
                                label: 'Brush',
                                icon: Icons.brush,
                                isDone: taskLog.brushDone,
                                onTap: () => notifier.completeTask(TaskType.brush),
                              ),
                              _buildTaskButton(
                                label: 'Cuddle',
                                icon: Icons.favorite,
                                isDone: taskLog.cuddleDone,
                                onTap: () => notifier.completeTask(TaskType.cuddle),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          ),
        ),
      ),
    );
  }

  Widget _buildTaskButton({
    required String label,
    required IconData icon,
    required bool isDone,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: isDone ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDone ? Colors.grey[200]!.withValues(alpha: 0.8) : const Color(0xFFFFF9F8),
              shape: BoxShape.circle,
              boxShadow: isDone
                  ? []
                  : [
                      BoxShadow(
                        color: const Color(0xFFFFB5A7).withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Icon(
              isDone ? Icons.check : icon,
              color: isDone ? Colors.grey[500] : const Color(0xFFFFB5A7),
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDone ? Colors.grey : const Color(0xFF4A3E3D),
          ),
        ),
      ],
    );
  }
}
