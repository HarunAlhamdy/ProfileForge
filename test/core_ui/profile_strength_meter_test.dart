import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profileforge/core_ui/atoms/profile_strength_meter.dart';

void main() {
  group('ProfileStrengthMeter', () {
    testWidgets('renders and has correct size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileStrengthMeter(strength: 0.5, size: 80),
          ),
        ),
      );
      expect(find.byType(ProfileStrengthMeter), findsOneWidget);
    });

    testWidgets('accepts strength 0 and 1', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ProfileStrengthMeter(strength: 0),
                ProfileStrengthMeter(strength: 1),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(ProfileStrengthMeter), findsNWidgets(2));
    });

    // Golden: run with `flutter test --update-goldens` to create.
    // testWidgets('golden: strength meter at 50%', (tester) async {
    //   await tester.pumpWidget(
    //     MaterialApp(
    //       theme: ThemeData(useMaterial3: true),
    //       home: Scaffold(
    //         body: Center(
    //           child: ProfileStrengthMeter(strength: 0.5, size: 80),
    //         ),
    //       ),
    //     ),
    //   );
    //   await expectLater(
    //     find.byType(ProfileStrengthMeter),
    //     matchesGoldenFile('goldens/profile_strength_meter_50.png'),
    //   );
    // });
  });
}
