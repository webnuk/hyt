import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_exception.dart';
import '../../auth/application/auth_controller.dart';
import '../application/booking_providers.dart';
import '../domain/booking_target.dart';

/// The "Book Now" form — no payment, no login required. Submitting sends the
/// enquiry straight to the tour/hotel's operator (see
/// BookingEnquiryRepository / the server's BookingEnquiry model); Host Your
/// Tour is cc'd on the email and keeps its own record of every enquiry.
class BookingEnquiryScreen extends ConsumerStatefulWidget {
  const BookingEnquiryScreen({super.key, required this.target});

  final BookingTarget target;

  @override
  ConsumerState<BookingEnquiryScreen> createState() => _BookingEnquiryScreenState();
}

class _BookingEnquiryScreenState extends ConsumerState<BookingEnquiryScreen> {
  static final _isoFormat = DateFormat('yyyy-MM-dd');

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  final _dateController = TextEditingController();
  DateTime? _travelDate;
  bool _submitting = false;
  bool _sent = false;

  @override
  void initState() {
    super.initState();
    final customer = ref.read(authControllerProvider).valueOrNull;
    if (customer != null) {
      _nameController.text = customer.displayName;
      _emailController.text = customer.email;
      if (customer.phone != null) _phoneController.text = customer.phone!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _travelDate ?? today.add(const Duration(days: 7)),
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _travelDate = picked;
        _dateController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    try {
      final message = await ref.read(bookingEnquiryRepositoryProvider).submit(
            type: widget.target.type,
            slug: widget.target.slug,
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            message: _messageController.text.trim(),
            travelDate: _travelDate != null ? _isoFormat.format(_travelDate!) : null,
          );
      if (!mounted) return;
      setState(() => _sent = true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 4)));
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.firstFieldError ?? e.message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Now')),
      body: _sent ? _SentConfirmation(itemName: widget.target.name) : _buildForm(context),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.target.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              'Send your details and they\'ll go straight to the operator\'s team — no payment is taken here. '
              'They\'ll get back to you directly to confirm availability and arrange payment.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full name *'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email *'),
              validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone / WhatsApp *'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a phone number' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _dateController,
              readOnly: true,
              onTap: _pickDate,
              decoration: InputDecoration(
                labelText: 'Preferred travel date (optional)',
                hintText: 'Select a date',
                suffixIcon: _travelDate == null
                    ? const Icon(Icons.calendar_today)
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() {
                          _travelDate = null;
                          _dateController.clear();
                        }),
                      ),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _messageController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Message (optional)', alignLabelWithHint: true),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Send Enquiry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SentConfirmation extends StatelessWidget {
  const _SentConfirmation({required this.itemName});
  final String itemName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 84, color: Colors.green),
            const SizedBox(height: 24),
            Text('Enquiry sent!', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(
              'Your enquiry for $itemName has been sent. The operator\'s team will contact you directly to confirm availability and arrange payment.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
