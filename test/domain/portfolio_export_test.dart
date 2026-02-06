import 'package:flutter_test/flutter_test.dart';
import 'package:profileforge/features/profile/domain/models/profile_model.dart';
import 'package:profileforge/features/profile/domain/portfolio_export.dart';

void main() {
  group('portfolioToShareableText', () {
    test('includes name and ProfileForge footer for minimal profile', () {
      final p = const UserProfile(fullName: 'Jane Doe');
      final text = portfolioToShareableText(p);
      expect(text, contains('Jane Doe'));
      expect(text, contains('ProfileForge'));
    });

    test('includes headline and bio when set', () {
      final p = const UserProfile(
        fullName: 'Jane',
        headline: 'Engineer',
        bio: 'Hello world',
      );
      final text = portfolioToShareableText(p);
      expect(text, contains('Jane'));
      expect(text, contains('Engineer'));
      expect(text, contains('Hello world'));
    });

    test('includes skills as comma-separated', () {
      final p = const UserProfile(
        skills: [Skill(id: '1', name: 'Dart'), Skill(id: '2', name: 'Flutter')],
      );
      final text = portfolioToShareableText(p);
      expect(text, contains('Skills:'));
      expect(text, contains('Dart'));
      expect(text, contains('Flutter'));
    });

    test('includes experience entries', () {
      final p = const UserProfile(
        experience: [
          Experience(id: '1', role: 'Dev', company: 'Acme', period: '2020–Now'),
        ],
      );
      final text = portfolioToShareableText(p);
      expect(text, contains('Experience'));
      expect(text, contains('Dev'));
      expect(text, contains('Acme'));
      expect(text, contains('2020–Now'));
    });
  });
}
