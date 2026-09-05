import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/price_tag.dart';
import '../../booking/domain/booking_target.dart';
import '../application/hotel_providers.dart';
import '../domain/hotel_detail.dart';

class HotelDetailScreen extends ConsumerWidget {
  const HotelDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hotelAsync = ref.watch(hotelDetailProvider(slug));

    return Scaffold(
      body: hotelAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Could not load this hotel.\n$error', textAlign: TextAlign.center),
          ),
        ),
        data: (hotel) => _HotelDetailBody(hotel: hotel),
      ),
      bottomNavigationBar: hotelAsync.maybeWhen(
        data: (hotel) => _BookingBar(hotel: hotel),
        orElse: () => null,
      ),
    );
  }
}

class _HotelDetailBody extends StatelessWidget {
  const _HotelDetailBody({required this.hotel});
  final HotelDetail hotel;

  @override
  Widget build(BuildContext context) {
    final images = hotel.images.isNotEmpty ? hotel.images : [''];

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          // Explicit leading avoids AppBar's automatic back-button inference,
          // which was tripping "BoxConstraints forces an infinite width" on
          // this pushed route (Home's SliverAppBar never hits this path since
          // it's the shell root and can't pop, so it never got an implicit
          // leading widget).
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: PageView(
              children: images
                  .map((url) => url.isEmpty
                      ? Container(color: Colors.grey.shade300)
                      : CachedNetworkImage(imageUrl: url, fit: BoxFit.cover))
                  .toList(),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hotel.name, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 6),
                if (hotel.starRating > 0)
                  Row(
                    children: List.generate(
                      hotel.starRating,
                      (_) => const Icon(Icons.star, size: 18, color: Color(0xFFF5B301)),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(child: Text(hotel.address, style: TextStyle(color: Colors.grey.shade700))),
                  ],
                ),
                const Divider(height: 32),

                if (hotel.checkInTime.isNotEmpty || hotel.checkOutTime.isNotEmpty)
                  Row(
                    children: [
                      if (hotel.checkInTime.isNotEmpty)
                        Expanded(child: _TimeInfo(label: 'Check-in', time: hotel.checkInTime)),
                      if (hotel.checkOutTime.isNotEmpty)
                        Expanded(child: _TimeInfo(label: 'Check-out', time: hotel.checkOutTime)),
                    ],
                  ),
                const SizedBox(height: 20),

                if (hotel.description.isNotEmpty) ...[
                  Text('About', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(hotel.description, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 24),
                ],

                if (hotel.rooms.isNotEmpty) ...[
                  Text('Rooms', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  ...hotel.rooms.map((room) => _RoomTile(hotel: hotel, room: room)),
                ],

                if (hotel.cancellationPolicy?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 20),
                  Text('Cancellation Policy', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(hotel.cancellationPolicy!, style: Theme.of(context).textTheme.bodyMedium),
                ],

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TimeInfo extends StatelessWidget {
  const _TimeInfo({required this.label, required this.time});
  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        Text(time, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _RoomTile extends StatelessWidget {
  const _RoomTile({required this.hotel, required this.room});
  final HotelDetail hotel;
  final HotelRoom room;

  void _select(BuildContext context) {
    context.push(
      '/booking/enquiry',
      extra: BookingTarget.hotel(
        itemId: hotel.id,
        slug: hotel.slug,
        name: '${hotel.name} — ${room.name}',
        image: room.image.isNotEmpty ? room.image : (hotel.images.isNotEmpty ? hotel.images.first : ''),
        currencySymbol: room.currencySymbol,
        roomId: room.id,
        maxAdultsPerRoom: room.maxAdults,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _select(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: room.image.isEmpty
                      ? Container(color: Colors.grey.shade200)
                      : CachedNetworkImage(imageUrl: room.image, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(room.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      'Up to ${room.maxAdults} adults${room.maxChildren > 0 ? ', ${room.maxChildren} children' : ''}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 6),
                    PriceTag(amount: room.pricePerNight, currencySymbol: room.currencySymbol, suffix: '/ night', size: 14),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingBar extends StatelessWidget {
  const _BookingBar({required this.hotel});
  final HotelDetail hotel;

  @override
  Widget build(BuildContext context) {
    final cheapestRoom = hotel.rooms.isEmpty
        ? null
        : hotel.rooms.reduce((a, b) => a.pricePerNight <= b.pricePerNight ? a : b);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, -2))],
        ),
        child: Row(
          children: [
            Expanded(
              child: PriceTag(amount: hotel.minPrice, currencySymbol: hotel.currencySymbol, suffix: '/ night', size: 18),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              // The app-wide ElevatedButtonTheme sets minimumSize to
              // Size.fromHeight(52) — i.e. Size(double.infinity, 52) — for
              // full-width form buttons (Login/Register). That infinite
              // width crashes layout here since this button sits inline in
              // a Row next to the price tag, not in a full-width container.
              // Override with a bounded minimumSize to opt back out.
              style: ElevatedButton.styleFrom(minimumSize: const Size(160, 52)),
              onPressed: cheapestRoom == null
                  ? null
                  : () => context.push(
                        '/booking/enquiry',
                        extra: BookingTarget.hotel(
                          itemId: hotel.id,
                          slug: hotel.slug,
                          name: '${hotel.name} — ${cheapestRoom.name}',
                          image: hotel.images.isNotEmpty ? hotel.images.first : '',
                          currencySymbol: cheapestRoom.currencySymbol,
                          roomId: cheapestRoom.id,
                          maxAdultsPerRoom: cheapestRoom.maxAdults,
                        ),
                      ),
              child: const Text('Book Now'),
            ),
          ],
        ),
      ),
    );
  }
}
