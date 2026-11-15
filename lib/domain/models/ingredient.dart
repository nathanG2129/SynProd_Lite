class AdditionalIngredient {
  final String ingredientName;
  final double quantity;
  final String unit;
  final String? notes;
  final int sortOrder;

  const AdditionalIngredient({
    required this.ingredientName,
    required this.quantity,
    required this.unit,
    this.notes,
    this.sortOrder = 0,
  });

  AdditionalIngredient copyWith({
    String? ingredientName,
    double? quantity,
    String? unit,
    String? notes,
    int? sortOrder,
  }) {
    return AdditionalIngredient(
      ingredientName: ingredientName ?? this.ingredientName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ingredientName': ingredientName,
      'quantity': quantity,
      'unit': unit,
      'notes': notes,
      'sortOrder': sortOrder,
    };
  }

  factory AdditionalIngredient.fromMap(Map<String, dynamic> map) {
    return AdditionalIngredient(
      ingredientName: map['ingredientName'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'] as String,
      notes: map['notes'] as String?,
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }
}
