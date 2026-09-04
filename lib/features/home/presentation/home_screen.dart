import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/currency/currency_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../hotels/application/hotel_providers.dart';
import '../../hotels/presentation/widgets/hotel_card.dart';
import '../../tours/application/tour_providers.dart';
import '../../tours/presentation/widgets/tour_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredTours = ref.watch(featuredToursProvider);
    final featuredHotels = ref.watch(featuredHotelsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.darkNavy,
            expandedHeight: 180,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: const Text('Host Your Tour', style: TextStyle(fontSize: 18)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.darkNavy, AppColors.primaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(20, 60, 20, 0),
                  child: Text(
                    'Explore Bhutan, Your Way',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ),
            ),
            actions: const [_CurrencySelector(), SizedBox(width: 12)],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/tours'),
                      icon: const Icon(Icons.explore_outlined),
                      label: const Text('Browse Tours'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/hotels'),
                      icon: const Icon(Icons.hotel_outlined),
                      label: const Text('Browse Hotels'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _SectionHeader(title: 'Top-Rated Tours', onSeeAll: () => context.push('/tours')),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 300,
              child: featuredTours.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Could not load tours.\n$e', textAlign: TextAlign.center)),
                data: (tours) => tours.isEmpty
                    ? const Center(child: Text('No featured tours yet.'))
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: tours.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, i) => TourCard(tour: tours[i], width: 180),
                      ),
              ),
            ),
          ),
          _SectionHeader(title: 'Featured Hotels', onSeeAll: () => context.push('/hotels')),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 300,
              child: featuredHotels.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Could not load hotels.\n$e', textAlign: TextAlign.center)),
                data: (hotels) => hotels.isEmpty
                    ? const Center(child: Text('No featured hotels yet.'))
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: hotels.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, i) => HotelCard(hotel: hotels[i], width: 180),
                      ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeAll});
  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            TextButton(onPressed: onSeeAll, child: const Text('See all')),
          ],
        ),
      ),
    );
  }
}

class _CurrencySelector extends ConsumerWidget {
  const _CurrencySelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    return PopupMenuButton<String>(
      initialValue: currency,
      onSelected: (value) => ref.read(currencyProvider.notifier).set(value),
      itemBuilder: (context) => supportedCurrencies
          .map((c) => PopupMenuItem(value: c, child: Text(c)))
          .toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(currency, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            const Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
