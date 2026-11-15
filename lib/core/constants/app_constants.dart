class AppConstants {
  static const Duration sessionIdleTimeout = Duration(hours: 2);
  static const Duration sessionWarningBeforeTimeout = Duration(minutes: 15);
  static const Duration qrPairingExpiry = Duration(minutes: 10);

  static const double compositionTolerance = 0.01;
  static const double compositionTargetTotal = 100.0;

  static const int maxProductNameLength = 100;
  static const int maxProductDescriptionLength = 500;
  static const int maxComponentNameLength = 100;
  static const int maxIngredientNameLength = 100;
  static const int maxIngredientUnitLength = 20;
  static const int maxNotesLength = 255;
  static const int maxUserDisplayNameLength = 50;

  static const List<String> standardIngredientUnits = [
    'g',
    'kg',
    'ml',
    'l',
    'tsp',
    'tbsp',
  ];
}
