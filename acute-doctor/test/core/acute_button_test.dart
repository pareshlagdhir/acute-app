import 'package:acutework/core/theme/app_theme.dart';
import 'package:acutework/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AcuteButton renders label and responds to taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: AcuteButton(
            label: 'Verify and continue',
            onPressed: () => taps++,
          ),
        ),
      ),
    );

    expect(find.text('Verify and continue'), findsOneWidget);
    await tester.tap(find.byType(AcuteButton));
    await tester.pump();
    expect(taps, 1);
  });
}
