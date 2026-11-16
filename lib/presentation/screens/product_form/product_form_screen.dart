import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/error/failures.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/uuid_generator.dart';
import '../../../domain/models/composition.dart';
import '../../../domain/models/ingredient.dart';
import '../../../domain/models/product.dart';
import '../../../domain/models/product_type.dart';
import '../../../domain/services/product_validator.dart';
import '../../providers/device_providers.dart';
import '../../providers/product_providers.dart';
import '../../widgets/synprod_ui.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late ProductType _selectedType;

  final List<_CompositionRowState> _compositionRows = [];
  final List<_IngredientRowState> _ingredientRows = [];

  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.product;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _descriptionController =
        TextEditingController(text: existing?.description ?? '');
    _selectedType = existing?.productType ?? ProductType.greekYogurt;

    if (existing != null) {
      for (final comp in existing.compositions) {
        _compositionRows.add(_CompositionRowState.fromDomain(comp));
      }
      for (final ing in existing.additionalIngredients) {
        _ingredientRows.add(_IngredientRowState.fromDomain(ing));
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    for (final row in _compositionRows) {
      row.dispose();
    }
    for (final row in _ingredientRows) {
      row.dispose();
    }
    super.dispose();
  }

  List<Composition> _buildCompositions() {
    return List.generate(_compositionRows.length, (index) {
      final row = _compositionRows[index];
      return Composition(
        componentName: row.nameController.text.trim(),
        percentage: row.percentage,
        notes: row.notesController.text.trim().isEmpty
            ? null
            : row.notesController.text.trim(),
        sortOrder: index,
      );
    });
  }

  List<AdditionalIngredient> _buildIngredients() {
    return List.generate(_ingredientRows.length, (index) {
      final row = _ingredientRows[index];
      final parsedQty = double.tryParse(row.quantityController.text.trim()) ?? 0;
      final unit = row.isCustomUnit
          ? row.customUnitController.text.trim()
          : row.selectedUnit;
      return AdditionalIngredient(
        ingredientName: row.nameController.text.trim(),
        quantity: parsedQty,
        unit: unit,
        notes: row.notesController.text.trim().isEmpty
            ? null
            : row.notesController.text.trim(),
        sortOrder: index,
      );
    });
  }

  void _addCompositionRow() {
    setState(() {
      _compositionRows.add(_CompositionRowState());
    });
  }

  void _removeCompositionRow(int index) {
    setState(() {
      final removed = _compositionRows.removeAt(index);
      removed.dispose();
    });
  }

  void _updateCompositionPercentage(int index, double value) {
    final clamped = value.clamp(0.0, 100.0);
    final rounded = double.parse(clamped.toStringAsFixed(1));
    setState(() {
      final row = _compositionRows[index];
      row.percentage = rounded;
      row.percentageController.text = rounded.toStringAsFixed(1);
    });
  }

  void _fillTo100(int index) {
    final currentCompositions = _buildCompositions();
    final remaining =
        ProductValidator.calculateRemainingPercentage(currentCompositions);
    if (remaining <= 0) return;
    final target = (_compositionRows[index].percentage + remaining).clamp(0.0, 100.0);
    _updateCompositionPercentage(index, target);
  }

  void _addIngredientRow() {
    setState(() {
      _ingredientRows.add(_IngredientRowState());
    });
  }

  void _removeIngredientRow(int index) {
    setState(() {
      final removed = _ingredientRows.removeAt(index);
      removed.dispose();
    });
  }

  Future<void> _save() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final now = DateTime.now();
      final device = ref.read(currentDeviceProvider);
      final existing = widget.product;

      final candidate = Product(
        id: existing?.id ?? UuidGenerator.v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        productType: _selectedType,
        compositions: _buildCompositions(),
        additionalIngredients: _buildIngredients(),
        createdByDeviceId: existing?.createdByDeviceId ?? device.id,
        createdByDisplayName:
            existing?.createdByDisplayName ?? device.displayName,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
        isDeleted: existing?.isDeleted ?? false,
        version: existing?.version ?? 1,
      );

      await ref
          .read(productMutationServiceProvider)
          .saveProduct(candidate, isEditing: _isEditing);

      if (!mounted) return;
      final saved = await ref
          .read(productRepositoryProvider)
          .getProductById(candidate.id);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Updated "${candidate.name}"'
                : 'Created "${candidate.name}"',
          ),
          backgroundColor: AppTheme.greenSuccess,
        ),
      );
      Navigator.of(context).pop(saved ?? candidate);
    } on Failure catch (f) {
      if (!mounted) return;
      setState(() {
        _errorMessage = f.message;
      });
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to save product: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final compositions = _buildCompositions();
    final totalPercentage =
        ProductValidator.calculateTotalPercentage(compositions);
    final isSumValid = ProductValidator.isCompositionSumValid(compositions);

    return Scaffold(
      appBar: SynProdAppBar(
        title: Text(
          _isEditing ? 'Edit Product' : 'New Product',
          style: TextStyle(
            color: AppTheme.headingColorFor(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
            child: SynProdGradientButton(
              onPressed: _isSaving ? null : _save,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isSaving)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else
                    const Icon(Icons.save_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text(_isSaving ? 'Saving...' : 'Save'),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SynProdCanvas(
        child: Form(
          key: _formKey,
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorBgFor(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.inputErrorBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppTheme.redError, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: AppTheme.errorTextFor(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _buildBasicInfoCard(),
              const SizedBox(height: 16),
              _buildCompositionsCard(totalPercentage, isSumValid),
              const SizedBox(height: 16),
              _buildIngredientsCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return SynProdCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.headingColorFor(context),
            ),
          ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _nameController,
              maxLength: AppConstants.maxProductNameLength,
              decoration: const InputDecoration(
                labelText: 'Product Name *',
                hintText: 'e.g. Classic Greek Yogurt',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Product name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                final productTypes = ref.watch(productTypesProvider);
                final dropdownValue = productTypes.contains(_selectedType)
                    ? _selectedType
                    : (productTypes.isNotEmpty
                        ? productTypes.first
                        : _selectedType);
                return DropdownButtonFormField<ProductType>(
                  initialValue: dropdownValue,
                  decoration: const InputDecoration(
                    labelText: 'Product Type *',
                  ),
                  items: productTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(
                        '${type.displayName} (${type.baseWeightGrams.toInt()}g base)',
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedType = value);
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLength: AppConstants.maxProductDescriptionLength,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Optional production notes or flavor profile',
                alignLabelWithHint: true,
              ),
            ),
          ],
      ),
    );
  }

  Widget _buildCompositionsCard(double totalPercentage, bool isSumValid) {
    final isDark = AppTheme.isDark(context);
    final hasCompositions = _compositionRows.isNotEmpty;
    final statusColor = !hasCompositions
        ? AppTheme.secondaryTextFor(context)
        : (isSumValid
            ? AppTheme.headingColorFor(context)
            : AppTheme.warningTextFor(context));
    final statusBorder = !hasCompositions
        ? AppTheme.borderFor(context)
        : (isSumValid ? AppTheme.primaryOlive : AppTheme.amberWarning);
    final statusBg = !hasCompositions
        ? AppTheme.elevatedSurfaceFor(context)
        : (isSumValid
            ? (isDark
                ? AppTheme.darkPercentageValidBg
                : AppTheme.percentageValidBg)
            : AppTheme.warningBgFor(context));

    return SynProdCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Composition (% of Weight)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.headingColorFor(context),
                  ),
                ),
              ),
              SynProdSecondaryButton(
                onPressed: _addCompositionRow,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16),
                    SizedBox(width: 4),
                    Text('Add Row'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusBorder),
            ),
            child: Row(
              children: [
                Icon(
                  !hasCompositions
                      ? Icons.info_outline
                      : (isSumValid
                          ? Icons.check_circle_outline
                          : Icons.warning_amber_rounded),
                  color: statusColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    !hasCompositions
                        ? 'No composition rows (optional). Add rows to define % split.'
                        : isSumValid
                            ? 'Total: ${totalPercentage.toStringAsFixed(1)}% (Balanced at 100%)'
                            : 'Total: ${totalPercentage.toStringAsFixed(1)}% (Must equal 100%)',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_compositionRows.isNotEmpty) const SizedBox(height: 12),
          ...List.generate(_compositionRows.length, (index) {
            return _buildCompositionRow(index, totalPercentage);
          }),
        ],
      ),
    );
  }

  Widget _buildCompositionRow(int index, double totalPercentage) {
    final row = _compositionRows[index];
    final remaining = (100.0 - totalPercentage).clamp(0.0, 100.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.subtleSurfaceFor(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.cardBorderFor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Component #${index + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.secondaryTextFor(context),
                ),
              ),
              const Spacer(),
              if (remaining > 0.01)
                TextButton(
                  onPressed: () => _fillTo100(index),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text('Fill to 100%'),
                ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                tooltip: 'Remove component',
                onPressed: () => _removeCompositionRow(index),
              ),
            ],
          ),
          TextFormField(
            controller: row.nameController,
            maxLength: AppConstants.maxComponentNameLength,
            decoration: const InputDecoration(
              labelText: 'Component Name *',
              hintText: 'e.g. Strained Whole Milk Base',
              counterText: '',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Component name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton.outlined(
                onPressed: row.percentage > 0
                    ? () => _updateCompositionPercentage(
                        index, row.percentage - 0.5)
                    : null,
                icon: const Icon(Icons.remove, size: 16),
                tooltip: '-0.5%',
                visualDensity: VisualDensity.compact,
              ),
              Expanded(
                child: Slider(
                  value: row.percentage.clamp(0.0, 100.0),
                  min: 0.0,
                  max: 100.0,
                  divisions: 200,
                  activeColor: AppTheme.tealPrimary,
                  label: '${row.percentage.toStringAsFixed(1)}%',
                  onChanged: (val) => _updateCompositionPercentage(index, val),
                ),
              ),
              IconButton.outlined(
                onPressed: row.percentage < 100
                    ? () => _updateCompositionPercentage(
                        index, row.percentage + 0.5)
                    : null,
                icon: const Icon(Icons.add, size: 16),
                tooltip: '+0.5%',
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 82,
                child: TextFormField(
                  controller: row.percentageController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    suffixText: '%',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                  onChanged: (val) {
                    final parsed = double.tryParse(val);
                    if (parsed != null) {
                      setState(() {
                        row.percentage = parsed.clamp(0.0, 100.0);
                      });
                    }
                  },
                  validator: (val) {
                    final parsed = double.tryParse(val ?? '');
                    if (parsed == null || parsed <= 0 || parsed > 100) {
                      return '> 0';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: row.notesController,
            maxLength: AppConstants.maxNotesLength,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              counterText: '',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsCard() {
    return SynProdCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Additional Ingredients (per Base Unit)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.headingColorFor(context),
                  ),
                ),
              ),
              SynProdSecondaryButton(
                onPressed: _addIngredientRow,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16),
                    SizedBox(width: 4),
                    Text('Add Row'),
                  ],
                ),
              ),
            ],
          ),
          if (_ingredientRows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No additional ingredients added (optional).',
                style: TextStyle(
                  color: AppTheme.secondaryTextFor(context),
                  fontSize: 13,
                ),
              ),
            ),
          ...List.generate(_ingredientRows.length, (index) {
            return _buildIngredientRow(index);
          }),
        ],
      ),
    );
  }

  Widget _buildIngredientRow(int index) {
    final row = _ingredientRows[index];
    const otherUnitOption = 'Other';
    final unitOptions = [
      ...AppConstants.standardIngredientUnits,
      otherUnitOption,
    ];

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.subtleSurfaceFor(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.cardBorderFor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Ingredient #${index + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.secondaryTextFor(context),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                tooltip: 'Remove ingredient',
                onPressed: () => _removeIngredientRow(index),
              ),
            ],
          ),
          TextFormField(
            controller: row.nameController,
            maxLength: AppConstants.maxIngredientNameLength,
            decoration: const InputDecoration(
              labelText: 'Ingredient Name *',
              hintText: 'e.g. Natural Vanilla Extract',
              counterText: '',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ingredient name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: row.quantityController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Quantity *',
                    hintText: 'e.g. 2.5',
                  ),
                  validator: (val) {
                    final parsed = double.tryParse(val ?? '');
                    if (parsed == null || parsed <= 0) {
                      return 'Must be > 0';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: row.isCustomUnit
                      ? otherUnitOption
                      : row.selectedUnit,
                  decoration: const InputDecoration(
                    labelText: 'Unit *',
                  ),
                  items: unitOptions.map((u) {
                    return DropdownMenuItem(value: u, child: Text(u));
                  }).toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    setState(() {
                      if (val == otherUnitOption) {
                        row.isCustomUnit = true;
                      } else {
                        row.isCustomUnit = false;
                        row.selectedUnit = val;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          if (row.isCustomUnit) ...[
            const SizedBox(height: 10),
            TextFormField(
              controller: row.customUnitController,
              maxLength: AppConstants.maxIngredientUnitLength,
              decoration: const InputDecoration(
                labelText: 'Custom Unit *',
                hintText: 'e.g. drops, pinch',
                counterText: '',
              ),
              validator: (val) {
                if (row.isCustomUnit && (val == null || val.trim().isEmpty)) {
                  return 'Unit is required';
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 10),
          TextFormField(
            controller: row.notesController,
            maxLength: AppConstants.maxNotesLength,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              counterText: '',
            ),
          ),
        ],
      ),
    );
  }
}

class _CompositionRowState {
  final TextEditingController nameController;
  final TextEditingController percentageController;
  final TextEditingController notesController;
  double percentage;

  _CompositionRowState({
    String name = '',
    this.percentage = 0.0,
    String notes = '',
  })  : nameController = TextEditingController(text: name),
        percentageController = TextEditingController(
          text: percentage == 0.0 ? '0.0' : percentage.toStringAsFixed(1),
        ),
        notesController = TextEditingController(text: notes);

  factory _CompositionRowState.fromDomain(Composition comp) {
    return _CompositionRowState(
      name: comp.componentName,
      percentage: comp.percentage,
      notes: comp.notes ?? '',
    );
  }

  void dispose() {
    nameController.dispose();
    percentageController.dispose();
    notesController.dispose();
  }
}

class _IngredientRowState {
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController customUnitController;
  final TextEditingController notesController;
  String selectedUnit;
  bool isCustomUnit;

  _IngredientRowState({
    String name = '',
    String quantity = '',
    String unit = 'g',
    String notes = '',
  })  : nameController = TextEditingController(text: name),
        quantityController = TextEditingController(text: quantity),
        notesController = TextEditingController(text: notes),
        isCustomUnit = !AppConstants.standardIngredientUnits.contains(unit),
        selectedUnit = AppConstants.standardIngredientUnits.contains(unit)
            ? unit
            : AppConstants.standardIngredientUnits.first,
        customUnitController = TextEditingController(
          text: AppConstants.standardIngredientUnits.contains(unit) ? '' : unit,
        );

  factory _IngredientRowState.fromDomain(AdditionalIngredient ing) {
    final qtyText = ing.quantity == ing.quantity.roundToDouble()
        ? ing.quantity.toInt().toString()
        : ing.quantity.toString();
    return _IngredientRowState(
      name: ing.ingredientName,
      quantity: qtyText,
      unit: ing.unit,
      notes: ing.notes ?? '',
    );
  }

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    customUnitController.dispose();
    notesController.dispose();
  }
}
