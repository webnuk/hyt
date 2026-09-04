import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:host_your_tour/main.dart';

void main() {
  testWidgets('App boots to the splash screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: HostYourTourApp()));
    // Splash renders immediately; auth-state resolution (which needs network)
    // happens after, so we only assert the app boots without throwing.
    expect(find.text('Host Your Tour'), findsOneWidget);
  });
}
