import 'composition.dart';
import 'ingredient.dart';
import 'product_type.dart';

class Product {
  final String id;
  final String name;
  final String? description;
  final ProductType productType;
  final List<Composition> compositions;
  final List<AdditionalIngredient> additionalIngredients;
  final String createdByDeviceId;
  final String createdByDisplayName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final int version;

  const Product({
    required this.id,
    required this.name,
    this.description,
    required this.productType,
    this.compositions = const [],
    this.additionalIngredients = const [],
    required this.createdByDeviceId,
    required this.createdByDisplayName,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.version = 1,
  });

  Product copyWith({
    String? id,
    String? name,
    String? description,
    ProductType? productType,
    List<Composition>? compositions,
    List<AdditionalIngredient>? additionalIngredients,
    String? createdByDeviceId,
    String? createdByDisplayName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    int? version,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      productType: productType ?? this.productType,
      compositions: compositions ?? this.compositions,
      additionalIngredients:
          additionalIngredients ?? this.additionalIngredients,
      createdByDeviceId: createdByDeviceId ?? this.createdByDeviceId,
      createdByDisplayName: createdByDisplayName ?? this.createdByDisplayName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'productType': productType.code,
      'compositions': compositions.map((c) => c.toMap()).toList(),
      'additionalIngredients':
          additionalIngredients.map((i) => i.toMap()).toList(),
      'createdByDeviceId': createdByDeviceId,
      'createdByDisplayName': createdByDisplayName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
      'version': version,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      productType: ProductType.fromCode(map['productType'] as String),
      compositions: (map['compositions'] as List<dynamic>?)
              ?.map((item) => Composition.fromMap(item as Map<String, dynamic>))
              .toList() ??
          const [],
      additionalIngredients: (map['additionalIngredients'] as List<dynamic>?)
              ?.map((item) =>
                  AdditionalIngredient.fromMap(item as Map<String, dynamic>))
              .toList() ??
          const [],
      createdByDeviceId: map['createdByDeviceId'] as String,
      createdByDisplayName: map['createdByDisplayName'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isDeleted: (map['isDeleted'] as num?) == 1,
      version: (map['version'] as num?)?.toInt() ?? 1,
    );
  }
}
