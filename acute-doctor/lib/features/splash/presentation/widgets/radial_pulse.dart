import 'package:flutter/material.dart';

/// Concentric pulsing rings around the shield-with-cross logo (splash hero).
class RadialPulse extends StatelessWidget {
  const RadialPulse({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final r in const [280.0, 220.0, 160.0, 110.0])
            Container(
              width: r,
              height: r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              ),
            ),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
            ),
            child: const Icon(Icons.shield_outlined, color: Colors.white, size: 44),
          ),
          const Icon(Icons.add, color: Colors.white, size: 22),
        ],
      ),
    );
  }
}
