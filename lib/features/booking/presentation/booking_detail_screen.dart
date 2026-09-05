import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../application/booking_providers.dart';

class BookingDetailScreen extends ConsumerStatefulWidget {
  const BookingDetailScreen({super.key, required this.id});

  final int id;

  @override
  ConsumerState<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen> {
  bool _cancelling = false;

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel this booking?'),
        content: const Text('This can\'t be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep booking')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Cancel booking')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _cancelling = true);
    try {
      await ref.read(bookingRepositoryProvider).cancel(widget.id);
      ref.invalidate(bookingDetailProvider(widget.id));
      ref.read(myBookingsControllerProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking cancelled.')));
      }
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(bookingDetailProvider(widget.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(error is ApiException ? error.message : 'Could not load this booking.'),
        ),
        data: (booking) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(child: Text(booking.bookingReference, style: Theme.of(context).textTheme.titleLarge)),
                Chip(label: Text(booking.bookingStatus)),
              ],
            ),
            const SizedBox(height: 16),
            _Row('Type', booking.type == 'hotel' ? 'Hotel' : 'Tour'),
            _Row('Dates', '${booking.startDate} — ${booking.endDate}'),
            _Row('Travellers', '${booking.adults} adults, ${booking.children} children'),
            const Divider(height: 32),
            Text('Guest Details', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _Row('Name', booking.guestName),
            _Row('Email', booking.guestEmail),
            _Row('Phone', booking.guestPhone),
            if (booking.specialRequirements != null && booking.specialRequirements!.isNotEmpty)
              _Row('Special requests', booking.specialRequirements!),
            const Divider(height: 32),
            _Row('Total paid', 'Nu. ${booking.totalAmount.toStringAsFixed(2)}', bold: true),
            _Row('Payment status', booking.paymentStatus ?? 'N/A'),
            _Row('Booked on', booking.createdAt),
            if (booking.bookingStatus == 'confirmed') ...[
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: _cancelling ? null : _cancel,
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                child: _cancelling
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Cancel Booking'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.bold = false});
  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: TextStyle(color: Colors.grey.shade600))),
          Expanded(
            child: Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
