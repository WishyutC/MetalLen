import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metallens/app/metallens_app.dart';
import 'package:metallens/services/model_config.dart';

void main() {
  test('ONNX contract preserves the approved five-class order', () {
    expect(ModelConfig.inputName, 'input');
    expect(ModelConfig.outputName, 'logits');
    expect(ModelConfig.inputWidth, 64);
    expect(ModelConfig.inputHeight, 64);
    expect(ModelConfig.labels, const [
      'Rolled pit',
      'Inclusion',
      'Silk spot',
      'Deburring',
      'Waist folding',
    ]);
  });

  testWidgets('all four primary destinations are reachable', (tester) async {
    await tester.pumpWidget(const MetalLensApp());
    expect(find.text('MetalLens'), findsOneWidget);
    expect(find.text('Surface scan'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('nav-history')));
    await tester.pumpAndSettle();
    expect(find.text('Inspection history'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('nav-analytics')));
    await tester.pumpAndSettle();
    expect(find.text('Inspection overview · prototype data'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('nav-profile')));
    await tester.pumpAndSettle();
    expect(find.text('Inspector profile'), findsWidgets);
  });

  testWidgets('history can be filtered without losing navigation', (
    tester,
  ) async {
    await tester.pumpWidget(const MetalLensApp());
    await tester.tap(find.byKey(const ValueKey('nav-history')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Review'));
    await tester.pumpAndSettle();
    expect(find.text('Sheet A-1040'), findsOneWidget);
    expect(find.byKey(const ValueKey('nav-scanner')), findsOneWidget);
  });

  testWidgets('primary screens fit the minimum supported width',
      (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MetalLensApp());
    for (final destination in ['history', 'analytics', 'profile', 'scanner']) {
      await tester.tap(find.byKey(ValueKey('nav-$destination')));
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: '$destination must fit a 320 × 700 viewport',
      );
    }
  });
}
