import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/hotels/presentation/hotel_detail_screen.dart';
import '../../features/hotels/presentation/hotels_list_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/tours/presentation/tour_detail_screen.dart';
import '../../features/tours/presentation/tours_list_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/', builder: (context, state) => const MainShell()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(path: '/tours', builder: (context, state) => const ToursListScreen()),
    GoRoute(
      path: '/tours/:slug',
      builder: (context, state) => TourDetailScreen(slug: state.pathParameters['slug']!),
    ),
    GoRoute(path: '/hotels', builder: (context, state) => const HotelsListScreen()),
    GoRoute(
      path: '/hotels/:slug',
      builder: (context, state) => HotelDetailScreen(slug: state.pathParameters['slug']!),
    ),
  ],
);
