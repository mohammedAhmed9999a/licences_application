import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Ministry Brand ─────────────────────────────────────────────────────────
  static const Color forest = Color(0xff002623);
  static const Color forest1 = Color(0xff054239);
  static const Color forest2 = Color(0xff428177);

  static const Color golden = Color(0xff988561);
  static const Color golden1 = Color(0xffb9a779);
  static const Color golden2 = Color(0xffedebe0);
  static const Color golden3 = Color(0xFFF9F5F0);

  static const Color grey = Color(0xff161616);
  static const Color grey1 = Color(0xff3d3a3b);
  static const Color grey2 = Color(0xffffffff);

  static const Color red = Color(0xff260f14);
  static const Color red1 = Color(0xff4a151e);
  static const Color red2 = Color(0xff6b1f2a);

  // ── Semantic ─────────────────────────────────────────────────────────────────
  static const Color primary = forest1;
  static const Color primaryLight = forest2;
  static const Color primaryDark = forest;
  static const Color accent = golden;
  static const Color accentLight = golden1;
  static const Color gold = golden;

  // ── Status ─────────────────────────────────────────────────────────────────
  static const Color statusConfirmed = forest2;
  static const Color statusPending = golden;
  static const Color statusCancelled = red2;
  static const Color statusCompleted = Color(0xff5c7a74);
  static const Color success = forest2;
  static const Color error = red2;
  static const Color warning = golden;
  static const Color info = Color(0xff1565C0);
  static const Color stepDone = statusCompleted;

  // ── Light Theme ────────────────────────────────────────────────────────────
  static const Color background = golden3;
  static const Color surface = grey2;
  static const Color surfaceVariant = golden2;
  static const Color border = Color(0xffDDD8C8);
  static const Color divider = Color(0xffE8E4D8);
  static const Color textPrimary = grey;
  static const Color textSecondary = grey1;
  static const Color textHint = Color(0xffA09880);

  // compatibility aliases for older code paths
  static const Color backgroundLight = background;
  static const Color backgroundAlt = Color(0xffEFE9DC);
  static const Color surfaceLight = surface;
  static const Color borderLight = border;
  static const Color textPrimaryLight = textPrimary;
  static const Color textSecondaryLight = textSecondary;
  static const Color textHintLight = textHint;
  static const Color selectedCardLight = Color(0xffF5F0E4);
  static const Color selectedCard = selectedCardLight;

  //  Dark Theme
  static const Color darkBg = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkSurfaceVariant = Color(0xFF14251D);
  static const Color darkSurfaceAlt = Color(0xFF0D1713);
  static const Color darkBorder = Color(0xFF2A6A4A);
  static const Color darkText = Color(0xFFF5F5F0);
  static const Color darkTextSecondary = Color(0xFF9BA89F);
  static const Color darkTextHint = Color(0xFF6F7A72);
  static const Color darkDivider = Color(0xFF1E3027);

  // compatibility aliases for older code paths
  static const Color backgroundDark = darkBg;
  static const Color backgroundDark2 = darkSurface;
  static const Color surfaceDark = darkSurfaceVariant;
  static const Color borderDark = darkBorder;
  static const Color textPrimaryDark = darkText;
  static const Color textSecondaryDark = darkTextSecondary;
  static const Color textHintDark = darkTextHint;
  static const Color selectedCardDark = Color(0xff1a2e23);

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [forest, forest1],
  );

  static const LinearGradient cardForestGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [forest1, forest2],
  );

  static const LinearGradient cardGoldenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [golden, golden1],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [forest, forest1, Color(0xff065248)],
  );
}
