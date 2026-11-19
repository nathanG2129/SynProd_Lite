class Composition {
  final String componentName;
  final double percentage;
  final String? notes;
  final int sortOrder;

  const Composition({
    required this.componentName,
    required this.percentage,
    this.notes,
    this.sortOrder = 0,
  });

  Composition copyWith({
    String? componentName,
    double? percentage,
    String? notes,
    int? sortOrder,
  }) {
    return Composition(
      componentName: componentName ?? this.componentName,
      percentage: percentage ?? this.percentage,
      notes: notes ?? this.notes,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'componentName': componentName,
      'percentage': percentage,
      'notes': notes,
      'sortOrder': sortOrder,
    };
  }

  factory Composition.fromMap(Map<String, dynamic> map) {
    return Composition(
      componentName: map['componentName'] as String,
      percentage: (map['percentage'] as num).toDouble(),
      notes: map['notes'] as String?,
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Composition &&
          runtimeType == other.runtimeType &&
          componentName == other.componentName &&
          percentage == other.percentage &&
          notes == other.notes &&
          sortOrder == other.sortOrder;

  @override
  int get hashCode =>
      Object.hash(componentName, percentage, notes, sortOrder);
}
