import 'package:flutter/material.dart';

import 'app_theme.dart';

class AppGradients {
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF07101D),
      Color(0xFF04070C),
      Color(0xFF170A0A),
    ],
  );

  static const LinearGradient splitDetective = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0B1A31),
      Color(0xFF07101D),
    ],
  );

  static const LinearGradient splitSuspect = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2A0C12),
      Color(0xFF0E0A11),
    ],
  );

  static const LinearGradient cinematicOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x22000000),
      Color(0xCC040507),
    ],
  );

  static const LinearGradient glassButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1AFFFFFF),
      Color(0x14070D18),
    ],
  );

  static const LinearGradient purpleGlow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.detectiveBlue,
      Color(0xFF9BC8FF),
    ],
  );

  static const LinearGradient greenGlow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.accentGreen,
      Color(0xFF34D399),
    ],
  );

  static const LinearGradient redGlow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.suspectRed,
      Color(0xFFFF7A7A),
    ],
  );
}
