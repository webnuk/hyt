import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/booking/domain/booking_flow.dart';
import '../../features/booking/domain/booking_target.dart';
import '../../features/booking/presentation/booking_confirm_screen.dart';
import '../../features/booking/presentation/booking_detail_screen.dart';
import '../../features/booking/presentation/booking_enquiry_screen.dart';
import '../../features/booking/presentation/booking_result_screen.dart';
import '../../features/booking/presentation/booking_summary_screen.dart';
import '../../features/booking/presentation/my_bookings_screen.dart';
import '../../features/booking/presentation/payment_webview_screen.dart';
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
    GoRoute(
      path: '/booking/enquiry',
      builder: (context, state) => BookingEnquiryScreen(target: state.extra! as BookingTarget),
    ),
    // Payment/RMA flow below is built but currently disconnected — see
    // BookingEnquiryScreen above, which "Book Now" actually points at.
    // Routing centralised payments for a multi-vendor marketplace (many
    // independent tour operators/hoteliers) creates real refund/chargeback/
    // tax liability that belongs with each operator, not Host Your Tour.
    // Kept reachable here so it's a clean flip to re-enable later.
    GoRoute(
      path: '/booking/summary',
      builder: (context, state) => BookingSummaryScreen(target: state.extra! as BookingTarget),
    ),
    GoRoute(
      path: '/booking/confirm/:token',
      builder: (context, state) => BookingConfirmScreen(bookingToken: state.pathParameters['token']!),
    ),
    GoRoute(
      path: '/booking/payment',
      builder: (context, state) => PaymentWebviewScreen(gateway: state.extra! as PaymentGatewayInfo),
    ),
    GoRoute(
      path: '/booking/result',
      builder: (context, state) => BookingResultScreen(status: state.extra as PaymentStatus?),
    ),
    GoRoute(path: '/account/bookings', builder: (context, state) => const MyBookingsScreen()),
    GoRoute(
      path: '/account/bookings/:id',
      builder: (context, state) => BookingDetailScreen(id: int.parse(state.pathParameters['id']!)),
    ),
  ],
);
