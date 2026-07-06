import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/city_screen.dart';
import 'screens/place_detail_screen.dart';
import 'screens/place_form_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'theme.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => _Shell(child: child),
        routes: [
          GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
          GoRoute(path: '/favorites', builder: (c, s) => const FavoritesScreen()),
          GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/city/:cityId',
        builder: (c, s) => CityScreen(cityId: int.parse(s.pathParameters['cityId']!)),
      ),
      GoRoute(
        path: '/place/:placeId',
        builder: (c, s) => PlaceDetailScreen(placeId: int.parse(s.pathParameters['placeId']!)),
      ),
      GoRoute(
        path: '/place-form',
        builder: (c, s) {
          final extra = s.extra as Map<String, dynamic>? ?? {};
          return PlaceFormScreen(
            cityId: extra['cityId'] as int?,
            placeId: extra['placeId'] as int?,
          );
        },
      ),
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
    ],
  );
});

class _Shell extends ConsumerStatefulWidget {
  final Widget child;
  const _Shell({required this.child});

  @override
  ConsumerState<_Shell> createState() => _ShellState();
}

class _ShellState extends ConsumerState<_Shell> {
  int _index = 0;

  static const _tabs = ['/', '/favorites', '/profile'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) {
          setState(() => _index = i);
          context.go(_tabs[i]);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Esplora'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: 'Preferiti'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profilo'),
        ],
      ),
    );
  }
}
