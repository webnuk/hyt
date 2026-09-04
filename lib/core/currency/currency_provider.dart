import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The currency the whole app displays prices in — passed as `?currency=`
/// to every tour/hotel API call (the API is stateless/session-independent
/// for this, see CurrencyHelper::forCurrency on the backend).
const supportedCurrencies = ['BTN', 'INR', 'USD'];

class CurrencyNotifier extends Notifier<String> {
  @override
  String build() => 'BTN';

  void set(String currency) {
    if (supportedCurrencies.contains(currency)) state = currency;
  }
}

final currencyProvider = NotifierProvider<CurrencyNotifier, String>(CurrencyNotifier.new);

String currencySymbolFor(String currency) {
  switch (currency) {
    case 'USD':
      return '\$';
    case 'INR':
      return 'Rs.';
    default:
      return 'Nu.';
  }
}
