import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:synprod_lite/data/local/database/app_database.dart';
import 'package:synprod_lite/main.dart';
import 'package:synprod_lite/presentation/providers/product_providers.dart';

void main() {
  testWidgets('SynProdLiteApp smoke test', (WidgetTester tester) async {
    final db = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: const SynProdLiteApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('SynProd Lite'), findsOneWidget);

    await db.close();
  });
}
