class PackagingOption {
  final String unitName;
  final double multiplier;

  const PackagingOption({
    required this.unitName,
    required this.multiplier,
  });
}

enum ProductType {
  greekYogurt(
    code: 'GREEK_YOGURT',
    displayName: 'Greek Yogurt',
    baseWeightGrams: 380.0,
    packagingOptions: [
      PackagingOption(unitName: 'Tubs', multiplier: 1.0),
    ],
  ),
  cheese(
    code: 'CHEESE',
    displayName: 'Cheese',
    baseWeightGrams: 400.0,
    packagingOptions: [
      PackagingOption(unitName: 'Tubs', multiplier: 1.0),
    ],
  ),
  drinks(
    code: 'DRINKS',
    displayName: 'Drinks',
    baseWeightGrams: 220.0,
    packagingOptions: [
      PackagingOption(unitName: 'Bottles', multiplier: 1.0),
      PackagingOption(unitName: 'Pouches', multiplier: 5.5),
    ],
  );

  final String code;
  final String displayName;
  final double baseWeightGrams;
  final List<PackagingOption> packagingOptions;

  const ProductType({
    required this.code,
    required this.displayName,
    required this.baseWeightGrams,
    required this.packagingOptions,
  });

  PackagingOption get defaultPackaging => packagingOptions.first;

  static ProductType fromCode(String code) {
    return ProductType.values.firstWhere(
      (type) => type.code == code || type.name == code,
      orElse: () => throw ArgumentError('Unknown product type code: $code'),
    );
  }
}
