class ThemeConfig {
  final String id;
  final String name;
  final String emoji;
  final String bgGradientFrom;
  final String? bgGradientVia;
  final String bgGradientTo;
  final String cardRounded;
  final String cardBorderColor;
  final String? cardBorderColorAlt;
  final String cardBorderWidth;
  final String cardBgColor;
  final String fontWeight;
  final String fontTransform;
  final String fontFamily;
  final String currentGlowColor;
  final String currentBgOverlay;
  final bool currentBorderEnhance;
  final bool? currentShadow;
  final String tickPastColor;
  final String tickCurrentColor;
  final String tickFutureColor;
  final String timeCardAccentColor;
  final String? timeCardAccentColorAlt;
  final Map<String, String> progressLineColors;
  final String progressBgColor;
  final String? specialEffect;

  ThemeConfig({
    required this.id,
    required this.name,
    this.emoji = '',
    required this.bgGradientFrom,
    this.bgGradientVia,
    required this.bgGradientTo,
    this.cardRounded = 'rounded-2xl',
    required this.cardBorderColor,
    this.cardBorderColorAlt,
    this.cardBorderWidth = '2px',
    this.cardBgColor = '#ffffff',
    this.fontWeight = '500',
    this.fontTransform = 'none',
    this.fontFamily = 'sans-serif',
    required this.currentGlowColor,
    required this.currentBgOverlay,
    this.currentBorderEnhance = false,
    this.currentShadow,
    required this.tickPastColor,
    required this.tickCurrentColor,
    required this.tickFutureColor,
    required this.timeCardAccentColor,
    this.timeCardAccentColorAlt,
    required this.progressLineColors,
    this.progressBgColor = '#d1d5db',
    this.specialEffect,
  });

  double get borderRadius {
    switch (cardRounded) {
      case 'rounded-sm':
        return 4;
      case 'rounded-md':
        return 8;
      case 'rounded-lg':
        return 12;
      case 'rounded-xl':
        return 16;
      case 'rounded-2xl':
        return 20;
      case 'rounded-3xl':
        return 24;
      default:
        return 16;
    }
  }

  double get borderWidthValue {
    return double.tryParse(cardBorderWidth.replaceAll('px', '')) ?? 2;
  }

  double get fontWeightValue {
    return double.tryParse(fontWeight) ?? 500;
  }

  ThemeConfig copyWith({
    String? id,
    String? name,
    String? emoji,
    String? bgGradientFrom,
    String? bgGradientVia,
    String? bgGradientTo,
    String? cardRounded,
    String? cardBorderColor,
    String? cardBorderColorAlt,
    String? cardBorderWidth,
    String? cardBgColor,
    String? fontWeight,
    String? fontTransform,
    String? fontFamily,
    String? currentGlowColor,
    String? currentBgOverlay,
    bool? currentBorderEnhance,
    bool? currentShadow,
    String? tickPastColor,
    String? tickCurrentColor,
    String? tickFutureColor,
    String? timeCardAccentColor,
    String? timeCardAccentColorAlt,
    Map<String, String>? progressLineColors,
    String? progressBgColor,
    String? specialEffect,
  }) {
    return ThemeConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      bgGradientFrom: bgGradientFrom ?? this.bgGradientFrom,
      bgGradientVia: bgGradientVia ?? this.bgGradientVia,
      bgGradientTo: bgGradientTo ?? this.bgGradientTo,
      cardRounded: cardRounded ?? this.cardRounded,
      cardBorderColor: cardBorderColor ?? this.cardBorderColor,
      cardBorderColorAlt: cardBorderColorAlt ?? this.cardBorderColorAlt,
      cardBorderWidth: cardBorderWidth ?? this.cardBorderWidth,
      cardBgColor: cardBgColor ?? this.cardBgColor,
      fontWeight: fontWeight ?? this.fontWeight,
      fontTransform: fontTransform ?? this.fontTransform,
      fontFamily: fontFamily ?? this.fontFamily,
      currentGlowColor: currentGlowColor ?? this.currentGlowColor,
      currentBgOverlay: currentBgOverlay ?? this.currentBgOverlay,
      currentBorderEnhance: currentBorderEnhance ?? this.currentBorderEnhance,
      currentShadow: currentShadow ?? this.currentShadow,
      tickPastColor: tickPastColor ?? this.tickPastColor,
      tickCurrentColor: tickCurrentColor ?? this.tickCurrentColor,
      tickFutureColor: tickFutureColor ?? this.tickFutureColor,
      timeCardAccentColor: timeCardAccentColor ?? this.timeCardAccentColor,
      timeCardAccentColorAlt:
          timeCardAccentColorAlt ?? this.timeCardAccentColorAlt,
      progressLineColors: progressLineColors ?? this.progressLineColors,
      progressBgColor: progressBgColor ?? this.progressBgColor,
      specialEffect: specialEffect ?? this.specialEffect,
    );
  }
}
