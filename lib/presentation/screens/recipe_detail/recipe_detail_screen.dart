import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/product.dart';
import '../../../domain/models/product_type.dart';
import '../../../domain/services/order_calculator.dart';
import 'services/recipe_pdf_generator.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Product product;

  const RecipeDetailScreen({super.key, required this.product});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late PackagingOption _selectedPackaging;
  late TextEditingController _quantityController;
  late TextEditingController _totalWeightController;
  late FocusNode _quantityFocusNode;
  late FocusNode _totalWeightFocusNode;

  double _currentQuantity = 1.0;
  bool _isExportingPdf = false;

  final NumberFormat _weightFormatter = NumberFormat('#,##0', 'en_US');
  final NumberFormat _decimalFormatter = NumberFormat('#,##0.0#', 'en_US');

  @override
  void initState() {
    super.initState();
    _selectedPackaging = widget.product.productType.packagingOptions.first;

    _quantityController = TextEditingController(text: '1');
    _totalWeightController = TextEditingController();

    _quantityFocusNode = FocusNode();
    _totalWeightFocusNode = FocusNode();

    _recalculateFromQuantity(1.0);

    _quantityFocusNode.addListener(() {
      if (!_quantityFocusNode.hasFocus) {
        _handleQuantityBlur();
      }
    });

    _totalWeightFocusNode.addListener(() {
      if (!_totalWeightFocusNode.hasFocus) {
        _handleTotalWeightBlur();
      }
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _totalWeightController.dispose();
    _quantityFocusNode.dispose();
    _totalWeightFocusNode.dispose();
    super.dispose();
  }

  void _recalculateFromQuantity(double qty) {
    final sanitizedQty = qty < 0 ? 0.0 : qty;
    final total = OrderCalculatorService.calculateTotalWeight(
      baseWeightGrams: widget.product.productType.baseWeightGrams,
      orderQuantity: sanitizedQty,
      unitMultiplier: _selectedPackaging.multiplier,
    );

    setState(() {
      _currentQuantity = sanitizedQty;
      if (!_totalWeightFocusNode.hasFocus) {
        _totalWeightController.text = total.toStringAsFixed(1);
      }
    });
  }

  void _recalculateFromTotalWeight(double totalWeight) {
    final sanitizedTotal = totalWeight < 0 ? 0.0 : totalWeight;
    final qty = OrderCalculatorService.calculateOrderQuantity(
      baseWeightGrams: widget.product.productType.baseWeightGrams,
      totalWeightGrams: sanitizedTotal,
      unitMultiplier: _selectedPackaging.multiplier,
    );

    setState(() {
      _currentQuantity = qty;
      if (!_quantityFocusNode.hasFocus) {
        _quantityController.text = qty == qty.roundToDouble()
            ? qty.toInt().toString()
            : qty.toString();
      }
    });
  }

  void _handleQuantityBlur() {
    final parsed = double.tryParse(_quantityController.text.trim()) ?? 0.0;
    final clamped = parsed < 0 ? 0.0 : parsed;
    final rounded = OrderCalculatorService.roundToDecimals(
        clamped, OrderCalculatorService.quantityDecimals);

    _quantityController.text = rounded == rounded.roundToDouble()
        ? rounded.toInt().toString()
        : rounded.toString();

    _recalculateFromQuantity(rounded);
  }

  void _handleTotalWeightBlur() {
    final parsed = double.tryParse(_totalWeightController.text.trim()) ?? 0.0;
    final clamped = parsed < 0 ? 0.0 : parsed;
    final rounded = clamped.roundToDouble();

    _totalWeightController.text = rounded.toInt().toString();
    _recalculateFromTotalWeight(rounded);
  }

  CalculationResult get _calculationResult {
    return OrderCalculatorService.calculateFromQuantity(
      productType: widget.product.productType,
      packagingOption: _selectedPackaging,
      orderQuantity: _currentQuantity,
      compositions: widget.product.compositions,
      ingredients: widget.product.additionalIngredients,
    );
  }

  Future<void> _exportPdf() async {
    setState(() => _isExportingPdf = true);
    try {
      await RecipePdfGenerator.printOrShare(
        product: widget.product,
        result: _calculationResult,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: AppTheme.redError,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExportingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _calculationResult;
    final isCompositionValid =
        (result.totalPercentage - 100.0).abs() <= AppConstants.compositionTolerance;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          IconButton(
            tooltip: 'Export / Print PDF (F3)',
            icon: _isExportingPdf
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf_outlined),
            onPressed: _isExportingPdf ? null : _exportPdf,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Info Card
            _buildProductInfoCard(),
            const SizedBox(height: 16),

            // Calculator Controls Card (F2)
            _buildCalculatorControlsCard(),
            const SizedBox(height: 16),

            // Composition Section
            _buildCompositionCard(result, isCompositionValid),
            const SizedBox(height: 16),

            // Additional Ingredients Section
            _buildIngredientsCard(result),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.tealLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.product.productType.displayName,
                    style: const TextStyle(
                      color: AppTheme.tealDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Base Unit: ${_weightFormatter.format(widget.product.productType.baseWeightGrams)} g',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.slate600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (widget.product.description != null &&
                widget.product.description!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                widget.product.description!,
                style: const TextStyle(fontSize: 14, color: AppTheme.slate700),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorControlsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calculate_outlined,
                    size: 20, color: AppTheme.tealPrimary),
                const SizedBox(width: 8),
                const Text(
                  'Order Capacity Calculator',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.slate900,
                  ),
                ),
                const Spacer(),
                // Packaging Unit Selector
                if (widget.product.productType.packagingOptions.length > 1)
                  DropdownButton<PackagingOption>(
                    value: _selectedPackaging,
                    underline: const SizedBox.shrink(),
                    borderRadius: BorderRadius.circular(8),
                    items: widget.product.productType.packagingOptions
                        .map((opt) => DropdownMenuItem(
                              value: opt,
                              child: Text(
                                '${opt.unitName} (×${opt.multiplier})',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedPackaging = val;
                          _recalculateFromQuantity(_currentQuantity);
                        });
                      }
                    },
                  )
                else
                  Text(
                    '${_selectedPackaging.unitName} (×${_selectedPackaging.multiplier})',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.slate600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Two-way Input: Order Quantity
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Quantity (${_selectedPackaging.unitName})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.slate700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _quantityController,
                        focusNode: _quantityFocusNode,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          hintText: '0',
                          isDense: true,
                        ),
                        onChanged: (text) {
                          final val = double.tryParse(text.trim()) ?? 0.0;
                          _recalculateFromQuantity(val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Icon(Icons.sync_alt, color: AppTheme.slate400),
                ),
                const SizedBox(width: 16),
                // Two-way Input: Total Batch Weight
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Batch Weight (g)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.slate700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _totalWeightController,
                        focusNode: _totalWeightFocusNode,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          hintText: '0',
                          isDense: true,
                        ),
                        onChanged: (text) {
                          final val = double.tryParse(text.trim()) ?? 0.0;
                          _recalculateFromTotalWeight(val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompositionCard(CalculationResult result, bool isValid) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Batch Composition',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.slate900,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isValid
                        ? AppTheme.greenSuccess.withAlpha(25)
                        : AppTheme.amberWarning.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isValid
                          ? AppTheme.greenSuccess.withAlpha(80)
                          : AppTheme.amberWarning.withAlpha(80),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isValid ? Icons.check_circle : Icons.warning_amber,
                        size: 14,
                        color: isValid
                            ? AppTheme.greenSuccess
                            : AppTheme.amberWarning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isValid
                            ? '100% Balanced'
                            : 'Total: ${_decimalFormatter.format(result.totalPercentage)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isValid
                              ? AppTheme.greenSuccess
                              : AppTheme.amberWarning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            // Table Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: const [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Component',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.slate600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Base %',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.slate600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Calculated Weight',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.slate600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Rows
            ...result.components.map((comp) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        comp.composition.componentName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.slate900,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${_decimalFormatter.format(comp.composition.percentage)}%',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.slate700,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        '${_decimalFormatter.format(comp.calculatedWeightGrams)} g',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.slate900,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const Divider(),
            // Totals Row
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  const Expanded(
                    flex: 3,
                    child: Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.slate900,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${_decimalFormatter.format(result.totalPercentage)}%',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isValid
                            ? AppTheme.greenSuccess
                            : AppTheme.amberWarning,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      '${_decimalFormatter.format(result.totalWeightGrams)} g',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.slate900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsCard(CalculationResult result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Ingredients',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.slate900,
              ),
            ),
            const SizedBox(height: 12),
            if (result.ingredients.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'No additional ingredients specified.',
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.slate600,
                  ),
                ),
              )
            else ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: const [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Ingredient',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.slate600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Base Qty',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.slate600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Calculated Batch',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.slate600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              ...result.ingredients.map((ing) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          ing.ingredient.ingredientName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.slate900,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${_decimalFormatter.format(ing.ingredient.quantity)} ${ing.ingredient.unit}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.slate700,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          '${_decimalFormatter.format(ing.calculatedQuantity)} ${ing.ingredient.unit}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.slate900,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
