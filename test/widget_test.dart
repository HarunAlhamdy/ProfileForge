import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:profileforge/main.dart';
import 'package:profileforge/features/profile/domain/models/profile_model.dart';
import 'package:profileforge/features/profile/presentation/providers/profile_provider.dart';

class _FakeProfileNotifier extends ProfileNotifier {
  @override
  Future<UserProfile> build() async => const UserProfile();
}

void main() {
  testWidgets('ProfileForge app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [profileProvider.overrideWith(_FakeProfileNotifier.new)],
        child: const ProfileForgeApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ProfileForge'), findsOneWidget);
  });
}
