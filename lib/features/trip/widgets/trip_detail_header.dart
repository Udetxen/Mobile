import 'package:flutter/material.dart';
import 'package:udetxen/features/trip/screens/trip_form_screen.dart';
import 'package:udetxen/features/trip/services/trip_service.dart';
import 'package:udetxen/shared/types/models/trip.dart';

class TripDetailHeader extends StatelessWidget {
  final Trip trip;
  final TripService tripService;

  const TripDetailHeader({
    super.key,
    required this.trip,
    required this.tripService,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            trip.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trip.creatorUid == null)
          ElevatedButton(
            onPressed: () async {
              final forkedTrip = await tripService.forkTrip(trip);
              Navigator.of(context).pushReplacement(
                TripFormScreen.route(trip: forkedTrip),
              );
            },
            child: const Text('Make a Plan'),
          ),
      ],
    );
  }
}
