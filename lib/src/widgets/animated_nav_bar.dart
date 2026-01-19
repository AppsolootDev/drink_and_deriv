import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class AnimatedNavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final bool isChanging;
  final VoidCallback onTap;
  final GlobalKey? showcaseKey;
  final String? description;

  const AnimatedNavBarItem({
    super.key,
    required this.icon,
    required this.isSelected,
    required this.isChanging,
    required this.onTap,
    this.showcaseKey,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    Widget item = GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Final state - subtle highlight (no border)
                if (isSelected && !isChanging)
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orange.withOpacity(0.1),
                    ),
                  ),

                // Base Icon (Hollow/Grey)
                Icon(
                  icon,
                  size: 28,
                  color: isSelected && !isChanging ? Colors.orange : Colors.grey.shade300,
                ),

                // Fill Animation on the Icon overlay
                if (isSelected && isChanging)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(seconds: 1),
                    builder: (context, value, child) {
                      return ClipRect(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          heightFactor: value,
                          child: Icon(
                            icon,
                            size: 28,
                            color: Colors.orange,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );

    if (showcaseKey != null && description != null) {
      return Showcase(
        key: showcaseKey!,
        description: description!,
        descTextStyle: const TextStyle(fontFamily: 'Josefine', fontSize: 12),
        child: item,
      );
    }

    return item;
  }
}
