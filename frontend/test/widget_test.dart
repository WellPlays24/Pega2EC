import 'package:flutter_test/flutter_test.dart';
import 'package:pega2_ec/src/app/app.dart';

void main() {
  testWidgets('renders pega2ec landing shell', (tester) async {
    await tester.pumpWidget(const Pega2EcApp());

    expect(find.text('Pega2EC'), findsOneWidget);
    expect(
      find.textContaining('La primera base web de Pega2EC'),
      findsOneWidget,
    );
  });
}
