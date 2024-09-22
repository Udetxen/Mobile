import 'package:flutter/material.dart';
import 'package:udetxen/features/auth/services/auth_service.dart';
import 'package:udetxen/features/dashboard.trip/screens/dashboard_trip_form_screen.dart';
import 'package:udetxen/features/dashboard.trip/services/dashboard_trip_service.dart';
import 'package:udetxen/features/trip/screens/trip_form_screen.dart';
import 'package:udetxen/features/trip/services/trip_service.dart';
import 'package:udetxen/shared/config/service_locator.dart';
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
    final DashboardTripService dashboardTripService =
        getIt<DashboardTripService>();

    return FutureBuilder(
      future: getIt<AuthService>().currentUser,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final user = snapshot.data!;

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
            if (trip.creatorUid == null) ...[
              if (user.isUser) ...[
                ElevatedButton(
                  onPressed: () async {
                    final forkedTrip = await tripService.forkTrip(trip);
                    Navigator.of(context).pushReplacement(
                      TripFormScreen.route(trip: forkedTrip, isForked: true),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Make a Plan'),
                ),
              ] else if (user.isAdmin) ...[
                ElevatedButton(
                  onPressed: () async {
                    await dashboardTripService.deleteTrip(trip.uid!);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Delete'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pushReplacement(
                      DashboardTripFormScreen.route(trip: trip),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Update'),
                ),
              ]
            ] else
              ElevatedButton(
                onPressed: () async {
                  await tripService.deleteTrip(trip.uid!);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Delete'),
              ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pushReplacement(
                  TripFormScreen.route(trip: trip),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
