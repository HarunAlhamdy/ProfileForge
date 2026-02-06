import 'package:flutter_test/flutter_test.dart';
import 'package:profileforge/features/profile/domain/models/profile_model.dart';
import 'package:profileforge/features/profile/domain/profile_strength.dart';

void main() {
  group('profileStrength', () {
    test('returns 0 for empty profile', () {
      expect(profileStrength(const UserProfile()), 0);
    });

    test('increases for fullName', () {
      expect(profileStrength(const UserProfile(fullName: 'Jane')), 0.2);
    });

    test('increases for headline', () {
      expect(profileStrength(const UserProfile(headline: 'Dev')), 0.15);
    });

    test('increases for bio', () {
      expect(profileStrength(const UserProfile(bio: 'Hello')), 0.2);
    });

    test('increases for email', () {
      expect(profileStrength(const UserProfile(email: 'a@b.com')), 0.1);
    });

    test('increases for skills', () {
      expect(
        profileStrength(const UserProfile(skills: [Skill(id: '1', name: 'Dart')])),
        0.15,
      );
    });

    test('increases for links', () {
      expect(
        profileStrength(const UserProfile(links: [ProfileLink(id: '1', title: 'X', url: 'https://x.com')])),
        0.1,
      );
    });

    test('increases for experience', () {
      expect(
        profileStrength(const UserProfile(experience: [Experience(id: '1', role: 'Dev')])),
        0.1,
      );
    });

    test('caps at 1.0 for full profile', () {
      expect(
        profileStrength(const UserProfile(
          fullName: 'A',
          headline: 'B',
          bio: 'C',
          email: 'e@e.com',
          skills: [Skill(id: '1', name: 'X')],
          links: [ProfileLink(id: '1', title: 'L', url: 'https://l.com')],
          experience: [Experience(id: '1', role: 'R')],
        )),
        1.0,
      );
    });
  });
}
