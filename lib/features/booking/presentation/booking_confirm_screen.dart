import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../auth/application/auth_controller.dart';
import '../application/booking_providers.dart';
import '../domain/booking_flow.dart';

class BookingConfirmScreen extends ConsumerStatefulWidget {
  const BookingConfirmScreen({super.key, required this.bookingToken});

  final String bookingToken;

  @override
  ConsumerState<BookingConfirmScreen> createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends ConsumerState<BookingConfirmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();
  bool _prefilled = false;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _prefillFrom(BookingReview review) {
    if (_prefilled) return;
    _prefilled = true;
    // getBookingDetails' `customer.name` reads the customers table's `name`
    // column directly, which is null for most accounts (see Customer.fromJson
    // — the API's populated field is `full_name`). Prefer the already-correct
    // Customer we resolved at sign-in and fall back to the review's own data.
    final customer = ref.read(authControllerProvider).valueOrNull;
    _nameController.text = customer?.displayName ?? review.customerName;
    _emailController.text = review.customerEmail.isNotEmpty ? review.customerEmail : (customer?.email ?? '');
    _phoneController.text = review.customerPhone.isNotEmpty ? review.customerPhone : (customer?.phone ?? '');
    _countryController.text =
        review.customerCountry.isNotEmpty ? review.customerCountry : (customer?.country ?? '');
  }

  Future<void> _confirmAndPay() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    try {
      final repo = ref.read(bookingRepositoryProvider);
      final confirmation = await repo.confirm(
        widget.bookingToken,
        guestFullName: _nameController.text.trim(),
        guestEmail: _emailController.text.trim(),
        guestPhone: _phoneController.text.trim(),
        guestCountry: _countryController.text.trim(),
      );
      final gateway = await repo.paymentUrl(confirmation.paymentId);
      if (!mounted) return;
      context.push('/booking/payment', extra: gateway);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.firstFieldError ?? e.message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewAsync = ref.watch(bookingReviewProvider(widget.bookingToken));

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Booking')),
      body: reviewAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error is ApiException
                  ? '${error.message}\n\nYour booking hold may have expired — go back and try again.'
                  : 'Could not load this booking.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (review) {
          _prefillFrom(review);
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (review.image.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(imageUrl: review.image, height: 160, width: double.infinity, fit: BoxFit.cover),
                ),
              const SizedBox(height: 12),
              Text(review.itemName, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                review.endDate.isEmpty ? review.startDate : '${review.startDate} — ${review.endDate}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              Text('Guest Details', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full name'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter the guest name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (v) =>
                          (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a phone number' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _countryController,
                      decoration: const InputDecoration(labelText: 'Country'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your country' : null,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: reviewAsync.maybeWhen(
        data: (_) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _submitting ? null : _confirmAndPay,
              child: _submitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Confirm & Pay'),
            ),
          ),
        ),
        orElse: () => null,
      ),
    );
  }
}
