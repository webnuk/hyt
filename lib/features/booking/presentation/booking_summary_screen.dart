import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_exception.dart';
import '../application/booking_providers.dart';
import '../domain/booking_target.dart';

class BookingSummaryScreen extends ConsumerStatefulWidget {
  const BookingSummaryScreen({super.key, required this.target});

  final BookingTarget target;

  @override
  ConsumerState<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends ConsumerState<BookingSummaryScreen> {
  static final _isoFormat = DateFormat('yyyy-MM-dd');

  late int _adults;
  int _children = 0;
  int _rooms = 1;
  late DateTime _travelDate; // tour: start date. hotel: check-in.
  late DateTime _checkOut; // hotel only.
  final _requestController = TextEditingController();
  bool _submitting = false;

  bool get _isHotel => widget.target.type == 'hotel';

  @override
  void initState() {
    super.initState();
    _adults = 2;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    _travelDate = _isHotel ? tomorrow : DateTime.now().add(const Duration(days: 5));
    _checkOut = tomorrow.add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _requestController.dispose();
    super.dispose();
  }

  BookingSummaryRequest get _request => (
        type: widget.target.type,
        slug: widget.target.slug,
        adults: _adults,
        children: _children,
        travelDate: _isHotel ? null : _isoFormat.format(_travelDate),
        roomId: _isHotel ? widget.target.roomId : null,
        checkinCheckout:
            _isHotel ? '${_isoFormat.format(_travelDate)} to ${_isoFormat.format(_checkOut)}' : null,
        rooms: _isHotel ? _rooms : null,
      );

  Future<void> _pickDate({required bool isCheckOut}) async {
    final initial = isCheckOut ? _checkOut : _travelDate;
    final firstDate = isCheckOut ? _travelDate.add(const Duration(days: 1)) : DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(firstDate) ? firstDate : initial,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isCheckOut) {
        _checkOut = picked;
      } else {
        _travelDate = picked;
        if (_isHotel && !_checkOut.isAfter(_travelDate)) {
          _checkOut = _travelDate.add(const Duration(days: 1));
        }
      }
    });
  }

  Future<void> _continue() async {
    setState(() => _submitting = true);
    try {
      final session = await ref.read(bookingRepositoryProvider).create(
            type: widget.target.type,
            itemId: widget.target.itemId,
            startDate: _isoFormat.format(_travelDate),
            endDate: _isHotel ? _isoFormat.format(_checkOut) : null,
            adults: _adults,
            children: _children,
            rooms: _isHotel ? _rooms : null,
            nights: _isHotel ? _checkOut.difference(_travelDate).inDays : null,
            specialRequirements: _requestController.text.trim(),
          );
      if (!mounted) return;
      context.push('/booking/confirm/${session.bookingToken}');
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.firstFieldError ?? e.message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(bookingSummaryProvider(_request));

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Summary')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(widget.target.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          _GuestStepper(
            label: 'Adults',
            value: _adults,
            minValue: 1,
            onChanged: (v) => setState(() => _adults = v),
          ),
          const SizedBox(height: 12),
          _GuestStepper(
            label: 'Children',
            value: _children,
            minValue: 0,
            onChanged: (v) => setState(() => _children = v),
          ),
          if (_isHotel) ...[
            const SizedBox(height: 12),
            _GuestStepper(label: 'Rooms', value: _rooms, minValue: 1, onChanged: (v) => setState(() => _rooms = v)),
          ],
          const SizedBox(height: 20),
          if (_isHotel) ...[
            _DateTile(label: 'Check-in', date: _travelDate, onTap: () => _pickDate(isCheckOut: false)),
            const SizedBox(height: 8),
            _DateTile(label: 'Check-out', date: _checkOut, onTap: () => _pickDate(isCheckOut: true)),
          ] else
            _DateTile(label: 'Travel date', date: _travelDate, onTap: () => _pickDate(isCheckOut: false)),
          const SizedBox(height: 20),
          TextField(
            controller: _requestController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Special requests (optional)',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          Text('Price breakdown', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          summaryAsync.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                error is ApiException ? error.message : 'Could not calculate the price.',
                style: const TextStyle(color: Colors.red),
              ),
            ),
            data: (summary) => Column(
              children: [
                _PriceRow('Subtotal', summary.netTotal, widget.target.currencySymbol),
                if (summary.discountAmount > 0)
                  _PriceRow('Discount', -summary.discountAmount, widget.target.currencySymbol),
                _PriceRow('Tax (${summary.taxRate.toStringAsFixed(0)}%)', summary.taxAmount, widget.target.currencySymbol),
                const Divider(),
                _PriceRow('Total', summary.total, widget.target.currencySymbol, bold: true),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            onPressed: _submitting ? null : _continue,
            child: _submitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Continue'),
          ),
        ),
      ),
    );
  }
}

class _GuestStepper extends StatelessWidget {
  const _GuestStepper({required this.label, required this.value, required this.minValue, required this.onChanged});

  final String label;
  final int value;
  final int minValue;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: value > minValue ? () => onChanged(value - 1) : null,
        ),
        SizedBox(width: 24, child: Text('$value', textAlign: TextAlign.center)),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => onChanged(value + 1),
        ),
      ],
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({required this.label, required this.date, required this.onTap});

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFDDDDDD)), borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 18),
            const SizedBox(width: 10),
            Text(label),
            const Spacer(),
            Text(DateFormat('dd MMM yyyy').format(date), style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow(this.label, this.amount, this.currencySymbol, {this.bold = false});

  final String label;
  final double amount;
  final String currencySymbol;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w400, fontSize: bold ? 17 : 14);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text('$currencySymbol ${amount.toStringAsFixed(2)}', style: style),
        ],
      ),
    );
  }
}
