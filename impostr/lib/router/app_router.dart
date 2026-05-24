import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/game_provider.dart';
import '../screens/home_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/setup_screen.dart';
import '../screens/card_reveal_screen.dart';
import '../screens/play_screen.dart';
import '../screens/vote_screen.dart';
import '../screens/result_screen.dart';
import '../screens/score_screen.dart';
import '../screens/legal/about_screen.dart';
import '../screens/legal/privacy_policy_screen.dart';
import '../screens/legal/terms_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/setup',
      builder: (context, state) => const SetupScreen(),
    ),
    GoRoute(
      path: '/reveal',
      builder: (context, state) => const _RevealRouteGate(),
    ),
    GoRoute(
      path: '/play',
      builder: (context, state) => const PlayScreen(),
    ),
    GoRoute(
      path: '/vote',
      builder: (context, state) => const VoteScreen(),
    ),
    GoRoute(
      path: '/result',
      builder: (context, state) => const ResultScreen(),
    ),
    GoRoute(
      path: '/score',
      builder: (context, state) => const ScoreScreen(),
    ),
    GoRoute(
      path: '/privacy-policy',
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: '/terms',
      builder: (context, state) => const TermsScreen(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
  ],
);

class _RevealRouteGate extends ConsumerStatefulWidget {
  const _RevealRouteGate();

  @override
  ConsumerState<_RevealRouteGate> createState() => _RevealRouteGateState();
}

class _RevealRouteGateState extends ConsumerState<_RevealRouteGate> {
  bool _redirected = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(gameProvider);

    if (session.roundNumber > 1) {
      if (!_redirected) {
        _redirected = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go('/play');
          }
        });
      }
      return const SizedBox.shrink();
    }

    return const CardRevealScreen();
  }
}
