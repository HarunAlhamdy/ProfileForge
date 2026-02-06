import 'models/profile_model.dart';

/// Computes profile completeness as a value in [0, 1].
double profileStrength(UserProfile profile) {
  var score = 0.0;
  if (profile.fullName.trim().isNotEmpty) score += 0.2;
  if (profile.headline.trim().isNotEmpty) score += 0.15;
  if (profile.bio.trim().isNotEmpty) score += 0.2;
  if (profile.email.trim().isNotEmpty) score += 0.1;
  if (profile.skills.isNotEmpty) score += 0.15;
  if (profile.links.isNotEmpty) score += 0.1;
  if (profile.experience.isNotEmpty) score += 0.1;
  return score.clamp(0.0, 1.0);
}
