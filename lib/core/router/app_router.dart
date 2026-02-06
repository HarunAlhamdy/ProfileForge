import 'package:go_router/go_router.dart';

import '../../features/forge/presentation/screens/forge_screen.dart';
import '../../features/profile/domain/models/profile_model.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/home_screen.dart';

final appRouter = GoRouter(
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
    GoRoute(
      path: '/forge',
      builder: (_, __) => const ForgeScreen(),
    ),
  ],
);
