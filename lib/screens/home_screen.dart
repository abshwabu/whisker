import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_math/vector_math_64.dart' as v;
import 'package:whisker/models/cat_state.dart';
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

  // Animation/Interaction States
  double _catScaleX = 1.0;
  double _catScaleY = 1.0;
  double _catOffsetX = 0.0;
  double _catOffsetY = 0.0;
  double _catRotation = 0.0;

  bool _isFeeding = false;
  bool _isBrushing = false;
  bool _isCuddling = false;
  bool _isPlayingGame = false;

  // Animation guards
  bool get _isAnimating => _isFeeding || _isBrushing || _isCuddling || _isPlayingGame;

  // Toy Position
  double _toyX = -90;
  double _toyY = 80;
  bool _pounced = false;
  bool _canPounce = false;

  // Particle List
  List<Map<String, dynamic>> _particles = [];
  bool _animateParticles = false;

  // Toast States
  bool _showUnlockToast = false;
  String _unlockedAccessory = '';

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

  // Particle Spawner
  void _spawnParticles({required IconData icon, required Color color, int count = 5}) {
    final random = Random();
    List<Map<String, dynamic>> newParticles = [];
    for (int i = 0; i < count; i++) {
      newParticles.add({
        'x': 0.0,
        'y': 0.0,
        'targetX': (random.nextDouble() - 0.5) * 160.0,
        'targetY': -80.0 - random.nextDouble() * 80.0,
        'icon': icon,
        'color': color,
        'size': 18.0 + random.nextDouble() * 12.0,
      });
    }
    setState(() {
      _particles = newParticles;
      _animateParticles = false;
    });
    // Trigger animation in next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _animateParticles = true;
        });
      }
    });
  }

  // Task Handlers
  Future<void> _handleFeed(CatNotifier notifier, CatState catState) async {
    if (_isAnimating) return;
    setState(() {
      _isFeeding = true;
    });

    // Cat bounce eating animation (quick bounce)
    for (int i = 0; i < 3; i++) {
      if (!mounted) return;
      setState(() {
        _catOffsetY = 8;
        _catScaleY = 0.92;
      });
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      setState(() {
        _catOffsetY = 0;
        _catScaleY = 1.0;
      });
      await Future.delayed(const Duration(milliseconds: 200));
    }

    if (!mounted) return;
    setState(() {
      _isFeeding = false;
    });

    await _executeTaskCompletion(notifier, catState, TaskType.feed);
  }

  Future<void> _handleBrush(CatNotifier notifier, CatState catState) async {
    if (_isAnimating) return;
    setState(() {
      _isBrushing = true;
      // Cat flattens contentedly and closes eyes (mood changes to content)
      _catScaleY = 0.88;
      _catOffsetY = 10;
      _catRotation = -0.02;
    });

    _spawnParticles(icon: Icons.star, color: const Color(0xFFFFD166), count: 6);

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      _catScaleY = 1.0;
      _catOffsetY = 0;
      _catRotation = 0.0;
    });

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      _isBrushing = false;
    });

    await _executeTaskCompletion(notifier, catState, TaskType.brush);
  }

  Future<void> _handleCuddle(CatNotifier notifier, CatState catState) async {
    if (_isAnimating) return;
    setState(() {
      _isCuddling = true;
    });

    _spawnParticles(icon: Icons.favorite, color: const Color(0xFFFF7B7B), count: 6);

    // Squish nuzzle animation (tilts left then right)
    setState(() {
      _catRotation = -0.06;
      _catScaleX = 1.08;
    });
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _catRotation = 0.06;
    });
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _catRotation = 0.0;
      _catScaleX = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _isCuddling = false;
    });

    await _executeTaskCompletion(notifier, catState, TaskType.cuddle);
  }

  void _handlePlay(CatNotifier notifier, CatState catState) async {
    if (_isAnimating) return;
    setState(() {
      _isPlayingGame = true;
      _pounced = false;
      _canPounce = true;
      _toyX = -90;
      _toyY = 80;
    });

    // Animate toy along path
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted || _pounced) return;
    setState(() {
      _toyX = -30;
      _toyY = -20;
    });

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted || _pounced) return;
    setState(() {
      _toyX = 30;
      _toyY = 20;
    });

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted || _pounced) return;
    setState(() {
      _toyX = 90;
      _toyY = 80;
    });

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    
    // Auto-complete if not tapped
    if (!_pounced) {
      _endPlay(notifier, catState);
    }
  }

  void _onToyTap(CatNotifier notifier, CatState catState) async {
    if (!_canPounce || _pounced) return;
    setState(() {
      _pounced = true;
      _canPounce = false;
      // Cat jumps/pounces towards the toy
      _catOffsetX = _toyX * 0.8;
      _catOffsetY = _toyY * 0.8 - 20;
      _catScaleX = 1.15;
      _catScaleY = 1.15;
    });

    // Pounce feedback
    HapticFeedback.mediumImpact();

    // Spawn sparkles on catch
    _spawnParticles(icon: Icons.star, color: const Color(0xFFFFD166), count: 7);

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _catOffsetX = 0;
      _catOffsetY = 0;
      _catScaleX = 1.0;
      _catScaleY = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _endPlay(notifier, catState);
  }

  void _endPlay(CatNotifier notifier, CatState catState) async {
    setState(() {
      _isPlayingGame = false;
    });
    await _executeTaskCompletion(notifier, catState, TaskType.play);
  }

  Future<void> _executeTaskCompletion(CatNotifier notifier, CatState catState, TaskType type) async {
    final oldUnlockedCount = catState.accessoriesUnlocked.length;

    // Trigger haptic feedback on completion
    HapticFeedback.lightImpact();

    await notifier.completeTask(type);

    final newCatState = ref.read(catProvider);
    final newUnlockedCount = newCatState.accessoriesUnlocked.length;

    if (newUnlockedCount > oldUnlockedCount) {
      final newlyUnlocked = newCatState.accessoriesUnlocked.firstWhere(
        (acc) => !catState.accessoriesUnlocked.contains(acc),
        orElse: () => '',
      );
      if (newlyUnlocked.isNotEmpty) {
        _triggerUnlockToast(newlyUnlocked);
      }
    }
  }

  void _triggerUnlockToast(String accessoryName) {
    HapticFeedback.heavyImpact();
    setState(() {
      _unlockedAccessory = accessoryName;
      _showUnlockToast = true;
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showUnlockToast = false;
        });
      }
    });
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

  Widget _buildUnlockToastCard() {
    IconData icon = Icons.workspace_premium;
    switch (_unlockedAccessory) {
      case 'Red Collar':
        icon = Icons.circle_notifications;
        break;
      case 'Yellow Bell':
        icon = Icons.notifications_active;
        break;
      case 'Pink Bow':
        icon = Icons.bookmark;
        break;
      case 'Wizard Hat':
        icon = Icons.brightness_3;
        break;
      case 'Crown':
        icon = Icons.workspace_premium;
        break;
    }

    return Card(
      color: const Color(0xFFFFF9F8),
      elevation: 6,
      shadowColor: const Color(0xFFFFB5A7).withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFFFB5A7), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFCD5CE),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF4A3E3D), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '✨ Accessory Unlocked!',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFB5A7),
                    ),
                  ),
                  Text(
                    _unlockedAccessory,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4A3E3D),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey, size: 20),
              onPressed: () {
                setState(() {
                  _showUnlockToast = false;
                });
              },
            ),
          ],
        ),
      ),
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
      body: Stack(
        children: [
          // Main Body Screen
          Container(
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
                                  letterSpacing: 1.2),
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

                            // Interactive Cat Stack
                            Center(
                              child: SizedBox(
                                width: 300,
                                height: 260,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Gentle floating animation wrapper
                                    AnimatedBuilder(
                                      animation: _floatController,
                                      builder: (context, child) {
                                        final floatOffset = sin(_floatController.value * pi * 2) * 8.0;
                                        return Transform.translate(
                                          offset: Offset(0, floatOffset),
                                          child: child,
                                        );
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        curve: Curves.easeInOut,
                                        transform: Matrix4.translationValues(_catOffsetX, _catOffsetY, 0.0)
                                          ..scaleByVector3(v.Vector3(_catScaleX, _catScaleY, 1.0))
                                          ..rotateZ(_catRotation),
                                        child: CatWidget(
                                          mood: catState.moodToday,
                                          bondLevel: catState.bondLevel,
                                          equippedAccessory: catState.equippedAccessory,
                                        ),
                                      ),
                                    ),

                                    // Feeding Bowl Slide-In
                                    AnimatedPositioned(
                                      duration: const Duration(milliseconds: 400),
                                      curve: Curves.easeOutBack,
                                      bottom: _isFeeding ? 35 : -50,
                                      right: 65,
                                      child: const Icon(
                                        Icons.rice_bowl,
                                        size: 44,
                                        color: Color(0xFF4A3E3D),
                                      ),
                                    ),

                                    // Sweeping Brush Animation
                                    AnimatedPositioned(
                                      duration: const Duration(milliseconds: 800),
                                      curve: Curves.easeInOut,
                                      top: 45,
                                      left: _isBrushing ? (_catScaleY == 0.88 ? 165 : 75) : -60,
                                      child: _isBrushing
                                          ? const Icon(
                                              Icons.brush,
                                              size: 44,
                                              color: Color(0xFFFFB5A7),
                                            )
                                          : const SizedBox(),
                                    ),

                                    // Interactive Play Toy (Yarn)
                                    if (_isPlayingGame)
                                      AnimatedPositioned(
                                        duration: const Duration(milliseconds: 700),
                                        curve: Curves.easeInOut,
                                        left: 150 + _toyX - 22,
                                        top: 130 + _toyY - 22,
                                        child: GestureDetector(
                                          onTap: () => _onToyTap(notifier, catState),
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFB5A7),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFFFFB5A7).withValues(alpha: 0.5),
                                                  blurRadius: 8,
                                                )
                                              ],
                                            ),
                                            child: const Icon(Icons.lens, size: 20, color: Colors.white),
                                          ),
                                        ),
                                      ),

                                    // Floating Hearts / Stars Particles
                                    for (var p in _particles)
                                      AnimatedPositioned(
                                        duration: const Duration(milliseconds: 1500),
                                        curve: Curves.easeOutCubic,
                                        left: 150 + (_animateParticles ? p['targetX'] : p['x']) - (p['size'] / 2) as double,
                                        top: 110 + (_animateParticles ? p['targetY'] : p['y']) - (p['size'] / 2) as double,
                                        child: AnimatedOpacity(
                                          duration: const Duration(milliseconds: 1500),
                                          opacity: _animateParticles ? 0.0 : 1.0,
                                          child: Icon(
                                            p['icon'],
                                            color: p['color'],
                                            size: p['size'],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),

                            // Instruction text for play mini-interaction
                            if (_isPlayingGame)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Text(
                                    'Tap the yarn before it rolls away!',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4A3E3D),
                                    ),
                                  ),
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
                                    onTap: () => _handleFeed(notifier, catState),
                                  ),
                                  _buildTaskButton(
                                    label: 'Play',
                                    icon: Icons.sports_esports,
                                    isDone: taskLog.playDone,
                                    onTap: () => _handlePlay(notifier, catState),
                                  ),
                                  _buildTaskButton(
                                    label: 'Brush',
                                    icon: Icons.brush,
                                    isDone: taskLog.brushDone,
                                    onTap: () => _handleBrush(notifier, catState),
                                  ),
                                  _buildTaskButton(
                                    label: 'Cuddle',
                                    icon: Icons.favorite,
                                    isDone: taskLog.cuddleDone,
                                    onTap: () => _handleCuddle(notifier, catState),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Sliding Unlock Toast Overlay Notification
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            top: _showUnlockToast ? 30 : -110,
            left: 20,
            right: 20,
            child: _buildUnlockToastCard(),
          ),
        ],
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
          onTap: (isDone || _isAnimating) ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDone
                  ? Colors.grey[200]!.withValues(alpha: 0.8)
                  : (_isAnimating ? Colors.white.withValues(alpha: 0.4) : const Color(0xFFFFF9F8)),
              shape: BoxShape.circle,
              boxShadow: (isDone || _isAnimating)
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
              color: isDone
                  ? Colors.grey[500]
                  : (_isAnimating ? Colors.grey[400] : const Color(0xFFFFB5A7)),
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
            color: isDone
                ? Colors.grey
                : (_isAnimating ? Colors.grey[400] : const Color(0xFF4A3E3D)),
          ),
        ),
      ],
    );
  }
}
