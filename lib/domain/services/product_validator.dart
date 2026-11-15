import '../../core/constants/app_constants.dart';
import '../../core/error/failures.dart';
import '../../core/utils/input_sanitizer.dart';
import '../models/composition.dart';
import '../models/product.dart';

class ProductValidator {
  static double calculateTotalPercentage(List<Composition> compositions) {
    return compositions.fold<double>(
      0.0,
      (sum, item) => sum + item.percentage,
    );
  }

  static double calculateRemainingPercentage(List<Composition> compositions) {
    final currentTotal = calculateTotalPercentage(compositions);
    final remaining = AppConstants.compositionTargetTotal - currentTotal;
    return remaining < 0 ? 0.0 : remaining;
  }

  static bool isCompositionSumValid(List<Composition> compositions) {
    if (compositions.isEmpty) return true;
    final total = calculateTotalPercentage(compositions);
    return (total - AppConstants.compositionTargetTotal).abs() <=
        AppConstants.compositionTolerance;
  }

  static void validateProduct(Product product) {
    InputSanitizer.sanitizeStrict(
      product.name,
      fieldName: 'Product name',
      maxLength: AppConstants.maxProductNameLength,
    );

    InputSanitizer.sanitizeOptional(
      product.description,
      fieldName: 'Description',
      maxLength: AppConstants.maxProductDescriptionLength,
    );

    for (var i = 0; i < product.compositions.length; i++) {
      final comp = product.compositions[i];
      final pos = i + 1;

      InputSanitizer.sanitizeStrict(
        comp.componentName,
        fieldName: 'Component name',
        position: pos,
        maxLength: AppConstants.maxComponentNameLength,
      );

      if (comp.percentage <= 0 || comp.percentage > 100) {
        throw ValidationFailure(
          'Composition percentage at position $pos must be between 0 and 100',
          field: 'percentage',
          position: pos,
        );
      }

      InputSanitizer.sanitizeOptional(
        comp.notes,
        fieldName: 'Composition notes',
        maxLength: AppConstants.maxNotesLength,
      );
    }

    if (product.compositions.isNotEmpty && !isCompositionSumValid(product.compositions)) {
      final currentTotal = calculateTotalPercentage(product.compositions);
      throw ValidationFailure(
        'Total composition percentage must equal 100%. Current total: ${currentTotal.toStringAsFixed(1)}%',
        field: 'compositions',
      );
    }

    for (var i = 0; i < product.additionalIngredients.length; i++) {
      final ing = product.additionalIngredients[i];
      final pos = i + 1;

      InputSanitizer.sanitizeStrict(
        ing.ingredientName,
        fieldName: 'Ingredient name',
        position: pos,
        maxLength: AppConstants.maxIngredientNameLength,
      );

      if (ing.quantity <= 0) {
        throw ValidationFailure(
          'Ingredient quantity at position $pos must be greater than 0',
          field: 'quantity',
          position: pos,
        );
      }

      InputSanitizer.sanitizeStrict(
        ing.unit,
        fieldName: 'Ingredient unit',
        position: pos,
        maxLength: AppConstants.maxIngredientUnitLength,
      );

      InputSanitizer.sanitizeOptional(
        ing.notes,
        fieldName: 'Ingredient notes',
        maxLength: AppConstants.maxNotesLength,
      );
    }
  }

  static void validateUniqueName({
    required String candidateName,
    required String currentProductId,
    required List<Product> existingProducts,
  }) {
    final normalized = candidateName.trim().toLowerCase();
    final duplicate = existingProducts.any((p) =>
        !p.isDeleted &&
        p.id != currentProductId &&
        p.name.trim().toLowerCase() == normalized);

    if (duplicate) {
      throw ConflictFailure("Product with name '$candidateName' already exists");
    }
  }
}
