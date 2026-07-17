import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whisker/providers/cat_provider.dart';
import 'package:whisker/services/accessory_seed.dart';

class ClosetScreen extends ConsumerWidget {
  const ClosetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catState = ref.watch(catProvider);
    final notifier = ref.read(catProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Closet'),
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header description
              const Text(
                'Dress Up Whisker',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A3E3D),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Unlock accessories by increasing your Closeness bond level with tasks.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),

              // Accessories Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: accessoriesList.length,
                  itemBuilder: (context, index) {
                    final accessory = accessoriesList[index];
                    final isUnlocked = catState.accessoriesUnlocked.contains(accessory.id) ||
                        catState.bondLevel >= accessory.bondLevelRequired;
                    final isEquipped = catState.equippedAccessory == accessory.id;

                    return Card(
                      elevation: 0,
                      color: isUnlocked
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.grey[200]!.withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: isEquipped
                            ? const BorderSide(color: Color(0xFFFFB5A7), width: 2)
                            : BorderSide.none,
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icon Preview
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: isUnlocked
                                      ? const Color(0xFFFCD5CE).withValues(alpha: 0.5)
                                      : Colors.grey[300],
                                  child: Icon(
                                    accessory.previewIcon,
                                    color: isUnlocked ? const Color(0xFF4A3E3D) : Colors.grey[600],
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Accessory Name
                                Text(
                                  accessory.displayName,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isUnlocked ? const Color(0xFF4A3E3D) : Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // Description / Lock message
                                if (isUnlocked)
                                  Expanded(
                                    child: Text(
                                      accessory.description,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 11,
                                      ),
                                    ),
                                  )
                                else
                                  Expanded(
                                    child: Text(
                                      'Locks: Closeness ${accessory.bondLevelRequired}%',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),

                                // Action Button
                                if (isUnlocked) ...[
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 36,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isEquipped
                                            ? const Color(0xFFFCD5CE)
                                            : const Color(0xFFFFB5A7),
                                        padding: EdgeInsets.zero,
                                      ),
                                      onPressed: () {
                                        if (isEquipped) {
                                          notifier.equipAccessory(null);
                                        } else {
                                          notifier.equipAccessory(accessory.id);
                                        }
                                      },
                                      child: Text(
                                        isEquipped ? 'Unequip' : 'Equip',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Top-right lock / check badge
                          Positioned(
                            top: 8,
                            right: 8,
                            child: isUnlocked
                                ? (isEquipped
                                    ? const Icon(Icons.check_circle, color: Color(0xFFFFB5A7), size: 20)
                                    : const SizedBox())
                                : const Icon(Icons.lock, color: Colors.grey, size: 20),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
