import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/api/api_exception.dart';
import '../application/booking_providers.dart';
import '../domain/booking_flow.dart';

/// Loads the RMA BFS Secure gateway as a POSTed HTML form (it's not a JSON
/// API — see BookingApiController::getPaymentUrl on the server). The bank's
/// return URL is fixed per merchant ID and can't be pointed at a deep link,
/// so once the webview navigates there we stop watching page content and
/// poll GET /payments/{id}/status instead to learn the real outcome.
class PaymentWebviewScreen extends ConsumerStatefulWidget {
  const PaymentWebviewScreen({super.key, required this.gateway});

  final PaymentGatewayInfo gateway;

  @override
  ConsumerState<PaymentWebviewScreen> createState() => _PaymentWebviewScreenState();
}

class _PaymentWebviewScreenState extends ConsumerState<PaymentWebviewScreen> {
  late final WebViewController _controller;
  bool _confirming = false;
  bool _pageLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (_isReturnUrl(url) && !_confirming) {
              _startConfirming();
            }
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _pageLoading = false);
          },
        ),
      )
      ..loadRequest(
        Uri.parse(widget.gateway.paymentUrl),
        method: LoadRequestMethod.post,
        headers: const {'Content-Type': 'application/x-www-form-urlencoded'},
        body: utf8.encode(Uri(queryParameters: widget.gateway.gatewayData).query),
      );
  }

  bool _isReturnUrl(String url) {
    return url.contains('/payment/success') || url.contains('/payment/failure') || url.contains('/payment/cancel');
  }

  Future<void> _startConfirming() async {
    setState(() => _confirming = true);
    final repo = ref.read(bookingRepositoryProvider);

    PaymentStatus? status;
    for (var attempt = 0; attempt < 10; attempt++) {
      await Future.delayed(const Duration(seconds: 2));
      try {
        status = await repo.paymentStatus(widget.gateway.paymentId);
      } on ApiException {
        continue; // transient — keep polling until attempts run out.
      }
      if (!status.isPending) break;
    }

    if (!mounted) return;
    context.pushReplacement('/booking/result', extra: status);
  }

  Future<bool> _confirmLeave() async {
    if (_confirming) return false; // already resolving — don't let the user bail mid-poll.
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel payment?'),
        content: const Text('You haven\'t finished paying yet. Are you sure you want to go back?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Stay')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Cancel payment')),
        ],
      ),
    );
    return leave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmLeave() && context.mounted) context.pop();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Payment')),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_pageLoading && !_confirming) const Center(child: CircularProgressIndicator()),
            if (_confirming)
              Container(
                color: Colors.black.withValues(alpha: 0.6),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text('Confirming your payment…', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
