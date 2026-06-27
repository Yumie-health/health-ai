import 'package:flutter/material.dart';
import '../services/streak_service.dart';
import '../utils/constants.dart';

class StreakBadge extends StatelessWidget {
  final Stream<StreakInfo> streakStream;
  final VoidCallback? onTap;

  const StreakBadge({Key? key, required this.streakStream, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StreakInfo>(
      stream: streakStream,
      builder: (context, snapshot) {
        final info = snapshot.data ?? StreakInfo.zero;
        final active = info.streakDays > 0;
        final flameColor = active ? Colors.orange : Colors.grey[400];

        return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color:
                  active
                      ? Colors.orange.withOpacity(0.12)
                      : Colors.grey.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: active ? Colors.orange : const Color(0xFFE5E7EB),
              ),
              boxShadow:
                  active
                      ? [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                      : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_fire_department, color: flameColor, size: 18),
                const SizedBox(width: 6),
                Text(
                  active ? '${info.streakDays}' : '0',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: active ? Colors.orange[800] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
