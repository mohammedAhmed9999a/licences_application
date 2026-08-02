import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ===========================
  // Brand
  // ===========================

  static const Color primary = Color(0xFF054239);
  static const Color primaryDark = Color(0xFF2F665E);
  static const Color primaryLight = Color(0xFF428177);

  static const Color secondary = Color(0xFFEDEBE0);
  static const Color secondaryDark = Color(0xFF002623);

  static const Color accent = Color(0xFFB9A779);
  static const Color accentLight = Color(0xFFE2DCC8);
  static const Color accentDark = Color(0xFFC5B78C);

  // ===========================
  // Background
  // ===========================

  static const Color background = Color(0xFFFBFAF5);
  static const Color backgroundDark = Color(0xFF0B0B0B);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF161616);

  // ===========================
  // Text
  // ===========================

  static const Color textPrimary = Color(0xFF161616);
  static const Color textSecondary = Color(0xFF3D3A3B);

  static const Color textPrimaryDark = Color(0xFFEDEBE0);
  static const Color textSecondaryDark = Color(0xFFB9A779);

  // ===========================
  // Borders & Input
  // ===========================

  static const Color border = Color(0xFFD8D3C9);
  static const Color borderDark = Color(0xFF3D3A3B);

  static const Color input = Color(0xFFD8D3C9);
  static const Color inputDark = Color(0xFF3D3A3B);

  static const Color focus = Color(0xFF2F665E);
  static const Color focusDark = Color(0xFF428177);

  // ===========================
  // Status
  // ===========================

  static const Color success = Color(0xFF428177);

  static const Color warning = Color(0xFFB9A779);

  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFF6B1F2A);

  // ===========================
  // Highlight
  // ===========================

  static const Color highlight = Color(0xFFE2DCC8);
  static const Color highlightBorder = Color(0xFFC5B78C);

  static const Color highlightDark = Color(0xFFB9A779);
  static const Color highlightBorderDark = Color(0xFFEDEBE0);

  // ===========================
  // Neutral
  // ===========================

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color charcoal950 = Color(0xFF0B0B0B);
  static const Color charcoal900 = Color(0xFF161616);
  static const Color charcoal800 = Color(0xFF211F20);
  static const Color charcoal700 = Color(0xFF2C292A);
  static const Color charcoal600 = Color(0xFF3D3A3B);
  static const Color charcoal500 = Color(0xFF6B6460);
  static const Color charcoal400 = Color(0xFF8B837B);
  static const Color charcoal300 = Color(0xFFB7B0A6);
  static const Color charcoal200 = Color(0xFFD8D3C9);
  static const Color charcoal100 = Color(0xFFF3F1ED);

  static const Color wheat950 = Color(0xFF2F281D);
  static const Color wheat800 = Color(0xFF5B503B);
  static const Color wheat700 = Color(0xFF77694C);
  static const Color wheat600 = Color(0xFF988561);
  static const Color wheat500 = Color(0xFFB9A779);
  static const Color wheat400 = Color(0xFFC5B78C);
  static const Color wheat200 = Color(0xFFE2DCC8);
  static const Color wheat100 = Color(0xFFEDEBE0);
  static const Color wheat50 = Color(0xFFFBFAF5);

  static const Color forest950 = Color(0xFF001412);
  static const Color forest900 = Color(0xFF002623);
  static const Color forest800 = Color(0xFF03332E);
  static const Color forest700 = Color(0xFF054239);
  static const Color forest600 = Color(0xFF2F665E);
  static const Color forest500 = Color(0xFF428177);
  static const Color forest200 = Color(0xFFB3D1CC);
  static const Color forest100 = Color(0xFFD8E8E5);
  static const Color forest50 = Color(0xFFEEF5F3);

  static const Color danger950 = Color(0xFF16080B);
  static const Color danger800 = Color(0xFF351017);
  static const Color danger700 = Color(0xFF4A151E);
  static const Color danger600 = Color(0xFF5A1A24);
  static const Color danger500 = Color(0xFF6B1F2A);

  static const Color destructive = Color(0xFFEF4444);

  // ===============================================================================================================================old Colors
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
  // static const Color primary = forest1;
  // static const Color primaryLight = forest2;
  // static const Color primaryDark = forest;
  // static const Color accent = golden;
  // static const Color accentLight = golden1;
  static const Color gold = golden;

  // ── Status ─────────────────────────────────────────────────────────────────
  static const Color statusConfirmed = forest2;
  static const Color statusPending = golden;
  static const Color statusCancelled = red2;
  static const Color statusCompleted = Color(0xff5c7a74);
  // static const Color success = forest2;
  // static const Color error = red2;
  // static const Color warning = golden;
  static const Color info = Color(0xff1565C0);
  static const Color stepDone = statusCompleted;

  // ── Light Theme ────────────────────────────────────────────────────────────
  // static const Color background = golden3;
  // static const Color surface = grey2;
  static const Color surfaceVariant = golden2;
  // static const Color border = Color(0xffDDD8C8);
  static const Color divider = Color(0xffE8E4D8);
  // static const Color textPrimary = grey;
  // static const Color textSecondary = grey1;
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
  static const Color selectedCardDark = Color(0xff1a2e23);
  static const Color selectedCardDark2 = Color(0xff233c31);
  static const Color selectedCardDark3 = selectedCardDark2;

  // compatibility aliases for older code paths
  // static const Color backgroundDark = darkBg;
  static const Color backgroundDark2 = darkSurface;
  // static const Color surfaceDark = darkSurfaceVariant;
  // static const Color borderDark = darkBorder;
  // static const Color textPrimaryDark = darkText;
  // static const Color textSecondaryDark = darkTextSecondary;
  static const Color textHintDark = darkTextHint;
  static const Color selectedCardDark1 = Color(0xff1a2e23);

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
