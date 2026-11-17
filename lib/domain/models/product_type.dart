import 'dart:convert';

class PackagingOption {
  final String unitName;
  final double multiplier;

  const PackagingOption({
    required this.unitName,
    required this.multiplier,
  });

  Map<String, dynamic> toMap() => {
        'unitName': unitName,
        'multiplier': multiplier,
      };

  factory PackagingOption.fromMap(Map<String, dynamic> map) {
    return PackagingOption(
      unitName: map['unitName'] as String,
      multiplier: (map['multiplier'] as num).toDouble(),
    );
  }
}

class ProductType {
  static const ProductType greekYogurt = ProductType(
    code: 'GREEK_YOGURT',
    displayName: 'Greek Yogurt',
    baseWeightGrams: 380.0,
    packagingOptions: [
      PackagingOption(unitName: 'Tubs', multiplier: 1.0),
    ],
    sortOrder: 0,
  );

  static const ProductType cheese = ProductType(
    code: 'CHEESE',
    displayName: 'Cheese',
    baseWeightGrams: 400.0,
    packagingOptions: [
      PackagingOption(unitName: 'Tubs', multiplier: 1.0),
    ],
    sortOrder: 1,
  );

  static const ProductType drinks = ProductType(
    code: 'DRINKS',
    displayName: 'Drinks',
    baseWeightGrams: 220.0,
    packagingOptions: [
      PackagingOption(unitName: 'Bottles', multiplier: 1.0),
      PackagingOption(unitName: 'Pouches', multiplier: 5.5),
    ],
    sortOrder: 2,
  );

  static const List<ProductType> defaults = [
    greekYogurt,
    cheese,
    drinks,
  ];

  final String code;
  final String displayName;
  final double baseWeightGrams;
  final List<PackagingOption> packagingOptions;
  final int sortOrder;
  final bool isArchived;

  const ProductType({
    required this.code,
    required this.displayName,
    required this.baseWeightGrams,
    required this.packagingOptions,
    this.sortOrder = 0,
    this.isArchived = false,
  });

  PackagingOption get defaultPackaging => packagingOptions.isNotEmpty
      ? packagingOptions.first
      : const PackagingOption(unitName: 'Units', multiplier: 1.0);

  ProductType copyWith({
    String? code,
    String? displayName,
    double? baseWeightGrams,
    List<PackagingOption>? packagingOptions,
    int? sortOrder,
    bool? isArchived,
  }) {
    return ProductType(
      code: code ?? this.code,
      displayName: displayName ?? this.displayName,
      baseWeightGrams: baseWeightGrams ?? this.baseWeightGrams,
      packagingOptions: packagingOptions ?? this.packagingOptions,
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toMap() => {
        'code': code,
        'displayName': displayName,
        'baseWeightGrams': baseWeightGrams,
        'packagingOptions': packagingOptions.map((p) => p.toMap()).toList(),
        'sortOrder': sortOrder,
        'isArchived': isArchived,
      };

  factory ProductType.fromMap(Map<String, dynamic> map) {
    final optionsRaw = map['packagingOptions'] as List<dynamic>? ?? const [];
    final options = optionsRaw
        .map((e) => PackagingOption.fromMap(e as Map<String, dynamic>))
        .toList();
    return ProductType(
      code: map['code'] as String,
      displayName: map['displayName'] as String,
      baseWeightGrams: (map['baseWeightGrams'] as num).toDouble(),
      packagingOptions: options.isNotEmpty
          ? options
          : const [PackagingOption(unitName: 'Units', multiplier: 1.0)],
      sortOrder: map['sortOrder'] as int? ?? 0,
      isArchived: map['isArchived'] as bool? ?? false,
    );
  }

  static List<PackagingOption> decodePackagingList(String rawJson) {
    final decoded = jsonDecode(rawJson) as List<dynamic>;
    final list = decoded
        .map((e) => PackagingOption.fromMap(e as Map<String, dynamic>))
        .toList();
    return list.isNotEmpty
        ? list
        : const [PackagingOption(unitName: 'Units', multiplier: 1.0)];
  }

  static String encodePackagingList(List<PackagingOption> options) {
    return jsonEncode(options.map((e) => e.toMap()).toList());
  }

  static ProductType fromCode(
    String code, {
    List<ProductType> catalog = defaults,
  }) {
    for (final type in catalog) {
      if (type.code == code) return type;
    }
    for (final type in defaults) {
      if (type.code == code) return type;
    }
    return ProductType(
      code: code,
      displayName: code,
      baseWeightGrams: 100.0,
      packagingOptions: const [PackagingOption(unitName: 'Units', multiplier: 1.0)],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductType &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}
