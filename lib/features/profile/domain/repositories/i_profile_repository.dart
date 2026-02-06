import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../models/profile_model.dart';

/// Repository contract for profile persistence.
/// Implementations: local (SharedPreferences), mock (in-memory), optional Isar.
abstract class IProfileRepository {
  Future<Either<Failure, UserProfile>> getProfile();
  Future<Either<Failure, Unit>> saveProfile(UserProfile profile);
}
