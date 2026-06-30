import 'package:flutter_test/flutter_test.dart';
import 'package:myrawapp/main.dart';

void main() {
  testWidgets('MyRawApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyRawApp());
    expect(find.byType(MyRawApp), findsOneWidget);
  });
}
