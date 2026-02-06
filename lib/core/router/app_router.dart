import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/discover/presentation/screens/discover_screen.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/forge/presentation/screens/forge_screen.dart';
import '../../features/profile/domain/models/profile_model.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/public_profile_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) {
              final profile = state.extra as UserProfile;
              return EditProfileScreen(profile: profile);
            },
          ),
        ],
      ),
      GoRoute(path: '/auth', builder: (_, __) => const AuthScreen()),
      GoRoute(path: '/discover', builder: (_, __) => const DiscoverScreen()),
      GoRoute(path: '/explore', builder: (_, __) => const ExploreScreen()),
      GoRoute(path: '/forge', builder: (_, __) => const ForgeScreen()),
      GoRoute(
        path: '/profile/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId'] ?? '';
          return PublicProfileScreen(userId: userId);
        },
      ),
    ],
    redirect: (context, state) => null,
  );
});
