import '../models/composition.dart';
import '../models/ingredient.dart';
import '../models/product_type.dart';

class CalculatedComponent {
  final Composition composition;
  final double calculatedWeightGrams;

  const CalculatedComponent({
    required this.composition,
    required this.calculatedWeightGrams,
  });
}

class CalculatedIngredient {
  final AdditionalIngredient ingredient;
  final double calculatedQuantity;

  const CalculatedIngredient({
    required this.ingredient,
    required this.calculatedQuantity,
  });
}

class CalculationResult {
  final double orderQuantity;
  final double totalWeightGrams;
  final PackagingOption packagingOption;
  final List<CalculatedComponent> components;
  final List<CalculatedIngredient> ingredients;
  final double totalPercentage;

  const CalculationResult({
    required this.orderQuantity,
    required this.totalWeightGrams,
    required this.packagingOption,
    required this.components,
    required this.ingredients,
    required this.totalPercentage,
  });
}

class OrderCalculatorService {
  static const int quantityDecimals = 6;

  static double roundToDecimals(double value, int decimals) {
    return double.parse(value.toStringAsFixed(decimals));
  }

  static double calculateTotalWeight({
    required double baseWeightGrams,
    required double orderQuantity,
    required double unitMultiplier,
  }) {
    if (orderQuantity < 0) return 0.0;
    return baseWeightGrams * orderQuantity * unitMultiplier;
  }

  static double calculateOrderQuantity({
    required double baseWeightGrams,
    required double totalWeightGrams,
    required double unitMultiplier,
  }) {
    if (totalWeightGrams <= 0 || baseWeightGrams <= 0 || unitMultiplier <= 0) {
      return 0.0;
    }
    final qty = totalWeightGrams / (baseWeightGrams * unitMultiplier);
    return roundToDecimals(qty < 0 ? 0.0 : qty, quantityDecimals);
  }

  static double calculateComponentWeight({
    required double totalWeightGrams,
    required double percentage,
  }) {
    if (totalWeightGrams <= 0 || percentage <= 0) return 0.0;
    return totalWeightGrams * percentage / 100.0;
  }

  static double calculateIngredientAmount({
    required double baseWeightGrams,
    required double totalWeightGrams,
    required double ingredientQuantity,
  }) {
    if (baseWeightGrams <= 0 || totalWeightGrams <= 0 || ingredientQuantity <= 0) {
      return 0.0;
    }
    return ingredientQuantity * (totalWeightGrams / baseWeightGrams);
  }

  static CalculationResult calculateFromQuantity({
    required ProductType productType,
    required PackagingOption packagingOption,
    required double orderQuantity,
    required List<Composition> compositions,
    required List<AdditionalIngredient> ingredients,
  }) {
    final sanitizedQty = orderQuantity < 0
        ? 0.0
        : roundToDecimals(orderQuantity, quantityDecimals);

    final totalWeight = calculateTotalWeight(
      baseWeightGrams: productType.baseWeightGrams,
      orderQuantity: sanitizedQty,
      unitMultiplier: packagingOption.multiplier,
    );

    final calculatedComponents = compositions.map((comp) {
      final compWeight = calculateComponentWeight(
        totalWeightGrams: totalWeight,
        percentage: comp.percentage,
      );
      return CalculatedComponent(
        composition: comp,
        calculatedWeightGrams: compWeight,
      );
    }).toList();

    final calculatedIngredients = ingredients.map((ing) {
      final ingAmount = calculateIngredientAmount(
        baseWeightGrams: productType.baseWeightGrams,
        totalWeightGrams: totalWeight,
        ingredientQuantity: ing.quantity,
      );
      return CalculatedIngredient(
        ingredient: ing,
        calculatedQuantity: ingAmount,
      );
    }).toList();

    final totalPercentage = compositions.fold<double>(
      0.0,
      (sum, item) => sum + item.percentage,
    );

    return CalculationResult(
      orderQuantity: sanitizedQty,
      totalWeightGrams: totalWeight,
      packagingOption: packagingOption,
      components: calculatedComponents,
      ingredients: calculatedIngredients,
      totalPercentage: totalPercentage,
    );
  }

  static CalculationResult calculateFromTotalWeight({
    required ProductType productType,
    required PackagingOption packagingOption,
    required double totalWeightGrams,
    required List<Composition> compositions,
    required List<AdditionalIngredient> ingredients,
  }) {
    final sanitizedTotalWeight = totalWeightGrams < 0 ? 0.0 : totalWeightGrams;

    final derivedQuantity = calculateOrderQuantity(
      baseWeightGrams: productType.baseWeightGrams,
      totalWeightGrams: sanitizedTotalWeight,
      unitMultiplier: packagingOption.multiplier,
    );

    return calculateFromQuantity(
      productType: productType,
      packagingOption: packagingOption,
      orderQuantity: derivedQuantity,
      compositions: compositions,
      ingredients: ingredients,
    );
  }
}
