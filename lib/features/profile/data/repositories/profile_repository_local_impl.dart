import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/models/profile_model.dart';
import '../../domain/repositories/i_profile_repository.dart';
import '../profile_storage.dart';

/// Local implementation using [ProfileStorage] (SharedPreferences).
class ProfileRepositoryLocalImpl implements IProfileRepository {
  ProfileRepositoryLocalImpl(this._storage);

  final ProfileStorage _storage;

  @override
  Future<Either<Failure, UserProfile>> getProfile() async {
    try {
      return Right(_storage.load());
    } catch (e, st) {
      return Left(CacheFailure('${e.toString()}\n$st'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveProfile(UserProfile profile) async {
    try {
      await _storage.save(profile);
      return const Right(unit);
    } catch (e, st) {
      return Left(CacheFailure('${e.toString()}\n$st'));
    }
  }
}
