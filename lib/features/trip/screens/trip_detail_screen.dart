import 'package:flutter/material.dart';
import 'package:udetxen/features/trip/services/trip_service.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:udetxen/shared/types/models/trip.dart';

import '../widgets/trip_detail_budget_card.dart';
import '../widgets/trip_detail_header.dart';
import '../widgets/trip_detail_image_card.dart';

class TripDetailScreen extends StatefulWidget {
  static route(String tripUid) {
    return MaterialPageRoute<void>(
      builder: (_) => TripDetailScreen(
        tripUid: tripUid,
      ),
    );
  }

  final String tripUid;

  const TripDetailScreen({super.key, required this.tripUid});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  final TripService _tripService = getIt<TripService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
        backgroundColor: Theme.of(context).hintColor,
      ),
      body: StreamBuilder<Trip>(
        stream: _tripService.getTrip(widget.tripUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading trip details'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No trip found'));
          }

          final trip = snapshot.data!;
          final participation = trip.participants != null &&
                  trip.participants?.isNotEmpty == true &&
                  trip.creatorUid != null
              ? trip.participants
                  ?.firstWhere((p) => p.participantUid == trip.creatorUid)
              : null;
          final totalExpense = trip.expenses?.fold<double>(
            0.0,
            (previousValue, element) =>
                previousValue + (element.expense ?? 0.0),
          );

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              TripDetailHeader(trip: trip, tripService: _tripService),
              const SizedBox(height: 16),
              TripDetailBudgetCard(trip: trip, totalExpense: totalExpense),
              const SizedBox(height: 16),
              if (trip.departure != null &&
                  trip.departure!.imageUrls.isNotEmpty)
                TripDetailImageCard(
                  imageUrls: trip.departure!.imageUrls,
                  title: 'From ${trip.departure!.name}',
                  locationName: trip.departure!.name,
                ),
              if (trip.destination != null &&
                  trip.destination!.imageUrls.isNotEmpty)
                TripDetailImageCard(
                  imageUrls: trip.destination!.imageUrls,
                  title: 'To ${trip.destination!.name}',
                  locationName: trip.destination!.name,
                ),
            ],
          );
        },
      ),
    );
  }
}
