import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/application/auth_controller.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final customer = authState.valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: authState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : customer == null
              ? _SignedOutView()
              : _SignedInView(customer: customer),
    );
  }
}

class _SignedOutView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_outline, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Sign in to book tours, save favourites, and view your bookings'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.push('/login'),
              child: const Text('Sign In'),
            ),
            TextButton(
              onPressed: () => context.push('/register'),
              child: const Text('Create an account'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignedInView extends ConsumerWidget {
  const _SignedInView({required this.customer});
  final dynamic customer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
          child: Text(
            customer.displayName.isNotEmpty ? customer.displayName[0].toUpperCase() : '?',
            style: const TextStyle(fontSize: 26, color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        Text(customer.displayName, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
        Text(customer.email, style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.receipt_long_outlined),
          title: const Text('My Bookings'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Booking history is coming soon.')),
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          onTap: () async {
            await ref.read(authControllerProvider.notifier).logout();
          },
        ),
      ],
    );
  }
}
