import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../domain/models/product.dart';
import '../../../../domain/services/order_calculator.dart';

class RecipePdfGenerator {
  static Future<Uint8List> generate({
    required Product product,
    required CalculationResult result,
  }) async {
    final pdf = pw.Document();

    final dateTimeStr = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    final numberFormat = NumberFormat('#,##0.0#', 'en_US');
    final wholeNumberFormat = NumberFormat('#,##0', 'en_US');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'SYNPROD LITE',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        product.name,
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blueGrey900,
                        ),
                      ),
                      if (product.description != null &&
                          product.description!.isNotEmpty) ...[
                        pw.SizedBox(height: 4),
                        pw.Text(
                          product.description!,
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.teal50,
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(6)),
                      border: pw.Border.all(color: PdfColors.teal200),
                    ),
                    child: pw.Text(
                      product.productType.displayName.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal800,
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 16),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 12),

              // Production Batch Summary
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(6)),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      'Order Quantity',
                      '${numberFormat.format(result.orderQuantity)} ${result.packagingOption.unitName}',
                    ),
                    _buildSummaryItem(
                      'Base Unit Weight',
                      '${wholeNumberFormat.format(product.productType.baseWeightGrams)} g',
                    ),
                    _buildSummaryItem(
                      'Unit Multiplier',
                      '×${result.packagingOption.multiplier}',
                    ),
                    _buildSummaryItem(
                      'Total Batch Weight',
                      '${wholeNumberFormat.format(result.totalWeightGrams)} g',
                      isHighlight: true,
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Section: Compositions Table
              pw.Text(
                'Batch Composition',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey900,
                ),
              ),
              pw.SizedBox(height: 8),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableCell('Component', isHeader: true),
                      _buildTableCell('Base %',
                          isHeader: true, align: pw.TextAlign.right),
                      _buildTableCell('Calculated Weight (g)',
                          isHeader: true, align: pw.TextAlign.right),
                    ],
                  ),
                  // Table Rows
                  ...result.components.map((comp) {
                    return pw.TableRow(
                      children: [
                        _buildTableCell(comp.composition.componentName),
                        _buildTableCell(
                          '${numberFormat.format(comp.composition.percentage)}%',
                          align: pw.TextAlign.right,
                        ),
                        _buildTableCell(
                          '${numberFormat.format(comp.calculatedWeightGrams)} g',
                          align: pw.TextAlign.right,
                        ),
                      ],
                    );
                  }),
                  // Totals Row
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.teal50),
                    children: [
                      _buildTableCell('Total', isHeader: true),
                      _buildTableCell(
                        '${numberFormat.format(result.totalPercentage)}%',
                        isHeader: true,
                        align: pw.TextAlign.right,
                      ),
                      _buildTableCell(
                        '${numberFormat.format(result.totalWeightGrams)} g',
                        isHeader: true,
                        align: pw.TextAlign.right,
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Section: Additional Ingredients Table
              pw.Text(
                'Additional Ingredients',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey900,
                ),
              ),
              pw.SizedBox(height: 8),

              if (result.ingredients.isEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 8),
                  child: pw.Text(
                    'No additional ingredients specified.',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                )
              else
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  children: [
                    pw.TableRow(
                      decoration:
                          const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        _buildTableCell('Ingredient', isHeader: true),
                        _buildTableCell('Base Qty (per unit)',
                            isHeader: true, align: pw.TextAlign.right),
                        _buildTableCell('Calculated Batch Qty',
                            isHeader: true, align: pw.TextAlign.right),
                        _buildTableCell('Unit', isHeader: true),
                      ],
                    ),
                    ...result.ingredients.map((ing) {
                      return pw.TableRow(
                        children: [
                          _buildTableCell(ing.ingredient.ingredientName),
                          _buildTableCell(
                            numberFormat.format(ing.ingredient.quantity),
                            align: pw.TextAlign.right,
                          ),
                          _buildTableCell(
                            numberFormat.format(ing.calculatedQuantity),
                            align: pw.TextAlign.right,
                          ),
                          _buildTableCell(ing.ingredient.unit),
                        ],
                      );
                    }),
                  ],
                ),

              pw.Spacer(),

              // Footer
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 6),
              pw.Text(
                'Generated on $dateTimeStr',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildSummaryItem(String label, String value,
      {bool isHighlight = false}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: isHighlight ? PdfColors.teal900 : PdfColors.blueGrey900,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.blueGrey900 : PdfColors.grey800,
        ),
      ),
    );
  }

  static Future<void> printOrShare({
    required Product product,
    required CalculationResult result,
  }) async {
    final pdfBytes = await generate(product: product, result: result);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: '${product.name.replaceAll(RegExp(r'\s+'), '_')}_Recipe.pdf',
    );
  }
}
