import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/price_tag.dart';
import '../../../shared/widgets/rating_stars.dart';
import '../../auth/application/auth_controller.dart';
import '../application/tour_providers.dart';
import '../domain/tour_detail.dart';
import 'widgets/tour_card.dart';

class TourDetailScreen extends ConsumerWidget {
  const TourDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tourAsync = ref.watch(tourDetailProvider(slug));

    return Scaffold(
      body: tourAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Could not load this tour.\n$error', textAlign: TextAlign.center),
          ),
        ),
        data: (tour) => _TourDetailBody(tour: tour),
      ),
      bottomNavigationBar: tourAsync.maybeWhen(
        data: (tour) => _BookingBar(tour: tour),
        orElse: () => null,
      ),
    );
  }
}

class _TourDetailBody extends StatelessWidget {
  const _TourDetailBody({required this.tour});
  final TourDetail tour;

  @override
  Widget build(BuildContext context) {
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
            background: tour.featuredImage.isEmpty
                ? Container(color: Colors.grey.shade300)
                : CachedNetworkImage(imageUrl: tour.featuredImage, fit: BoxFit.cover),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (tour.tourTypeName != null)
                  Text(
                    tour.tourTypeName!.toUpperCase(),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryBlue),
                  ),
                const SizedBox(height: 4),
                Text(tour.name, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  children: [
                    _InfoChip(icon: Icons.access_time, label: '${tour.durationDays} days'),
                    if (tour.locationNames != null) _InfoChip(icon: Icons.place_outlined, label: tour.locationNames!),
                    if (tour.reviewsCount > 0)
                      RatingStars(rating: tour.averageRating, size: 16, reviewsCount: tour.reviewsCount),
                  ],
                ),
                const Divider(height: 32),

                if (tour.shortDescription.isNotEmpty) ...[
                  Text(tour.shortDescription, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 20),
                ],

                if (tour.includes.isNotEmpty) ...[
                  Text("What's Included", style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tour.includes
                        .map((inc) => Chip(
                              label: Text(inc),
                              avatar: const Icon(Icons.check_circle, size: 16, color: Colors.green),
                              backgroundColor: Colors.green.withValues(alpha: 0.08),
                              side: BorderSide.none,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                if (tour.days.isNotEmpty) ...[
                  Text('Itinerary', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...tour.days.map((day) => _ItineraryDayTile(day: day)),
                  const SizedBox(height: 16),
                ],

                if (tour.reviews.isNotEmpty) ...[
                  Text('Traveller Reviews', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...tour.reviews.map((review) => _ReviewTile(review: review)),
                  const SizedBox(height: 16),
                ],

                if (tour.relatedTours.isNotEmpty) ...[
                  Text('Similar Tours', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 300,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: tour.relatedTours.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) => TourCard(tour: tour.relatedTours[i], width: 180),
                    ),
                  ),
                ],

                const SizedBox(height: 80), // clearance for the bottom booking bar
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade700),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
      ],
    );
  }
}

class _ItineraryDayTile extends StatelessWidget {
  const _ItineraryDayTile({required this.day});
  final TourDay day;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
          child: Text('${day.dayNumber}', style: const TextStyle(color: AppColors.primaryBlue, fontSize: 13)),
        ),
        title: Text(day.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(day.description)],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});
  final TourReview review;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(review.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                if (review.dateFormatted != null)
                  Text(review.dateFormatted!, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 4),
            RatingStars(rating: review.rating.toDouble()),
            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(review.comment),
            ],
          ],
        ),
      ),
    );
  }
}

class _BookingBar extends ConsumerWidget {
  const _BookingBar({required this.tour});
  final TourDetail tour;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

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
              child: PriceTag(amount: tour.price, currencySymbol: tour.currencySymbol, suffix: '/ person', size: 18),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                if (!isAuthenticated) {
                  context.push('/login');
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking flow is coming soon — enquire via WhatsApp for now.')),
                );
              },
              child: Text(isAuthenticated ? 'Book Now' : 'Sign In to Book'),
            ),
          ],
        ),
      ),
    );
  }
}
