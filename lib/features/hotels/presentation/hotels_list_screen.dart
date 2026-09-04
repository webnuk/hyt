import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/hotel_providers.dart';
import 'widgets/hotel_card.dart';

class HotelsListScreen extends ConsumerStatefulWidget {
  const HotelsListScreen({super.key});

  @override
  ConsumerState<HotelsListScreen> createState() => _HotelsListScreenState();
}

class _HotelsListScreenState extends ConsumerState<HotelsListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 300) {
        ref.read(hotelListControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hotelsAsync = ref.watch(hotelListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Hotels in Bhutan')),
      body: hotelsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 42, color: Colors.grey),
                const SizedBox(height: 12),
                Text('$error', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => ref.invalidate(hotelListControllerProvider),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
        data: (hotels) {
          if (hotels.isEmpty) return const Center(child: Text('No hotels found.'));
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(hotelListControllerProvider),
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.62,
              ),
              itemCount: hotels.length,
              itemBuilder: (context, index) => HotelCard(hotel: hotels[index]),
            ),
          );
        },
      ),
    );
  }
}
