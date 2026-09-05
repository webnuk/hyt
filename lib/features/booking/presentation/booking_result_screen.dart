import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/booking_flow.dart';

class BookingResultScreen extends StatelessWidget {
  const BookingResultScreen({super.key, required this.status});

  final PaymentStatus? status;

  @override
  Widget build(BuildContext context) {
    final success = status?.isSuccess ?? false;
    final unresolved = status == null || status!.isPending;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  unresolved
                      ? Icons.hourglass_top_rounded
                      : success
                          ? Icons.check_circle
                          : Icons.error,
                  size: 84,
                  color: unresolved
                      ? Colors.orange
                      : success
                          ? Colors.green
                          : AppColors.error,
                ),
                const SizedBox(height: 24),
                Text(
                  unresolved
                      ? 'Still confirming your payment'
                      : success
                          ? 'Booking confirmed!'
                          : 'Payment failed',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  unresolved
                      ? 'This is taking longer than expected. Check My Bookings shortly — we\'ll keep confirming in the background.'
                      : success
                          ? 'Your booking is confirmed. A confirmation has been sent to your email.'
                          : 'Your payment didn\'t go through. No amount has been booked — you can try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                if (status != null && status!.transactionId.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Transaction ID: ${status!.transactionId}', style: const TextStyle(fontSize: 12)),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => context.go('/account/bookings'),
                  child: const Text('View My Bookings'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
