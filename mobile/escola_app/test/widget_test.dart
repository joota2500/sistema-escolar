import 'package:flutter_test/flutter_test.dart';
import 'package:escola_app/main.dart';

void main() {
  testWidgets('App inicia corretamente', (WidgetTester tester) async {
    await tester.pumpWidget(const SistemaEscolarApp());

    expect(find.byType(SistemaEscolarApp), findsOneWidget);
  });
}
