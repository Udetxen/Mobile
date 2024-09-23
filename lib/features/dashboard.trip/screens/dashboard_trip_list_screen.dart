import 'package:flutter/material.dart';
import 'package:udetxen/features/trip/widgets/trip_card.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:udetxen/shared/types/models/trip.dart';
import 'package:udetxen/shared/widgets/layouts/authenticated_layout.dart';
import 'package:udetxen/shared/widgets/loader.dart';

import '../services/dashboard_trip_service.dart';
import 'dashboard_trip_form_screen.dart';

class DashboardTripListScreen extends StatefulWidget {
  static route() {
    return MaterialPageRoute<void>(
      builder: (_) => getInstance(),
    );
  }

  static Widget getInstance() {
    return const AuthenticatedLayout(
      isAdmin: true,
      currentIndex: 2,
    );
  }

  const DashboardTripListScreen({super.key});

  @override
  State<DashboardTripListScreen> createState() =>
      _DashboardTripListScreenState();
}

class _DashboardTripListScreenState extends State<DashboardTripListScreen> {
  late Stream<List<Trip>> _tripsStream;

  @override
  void initState() {
    super.initState();
    _tripsStream = getIt<DashboardTripService>().getAvailableTrips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Trips'),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Trip>>(
              stream: _tripsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loading();
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No available trips found.'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final trip = snapshot.data![index];
                      return TripCard(trip: trip);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(DashboardTripFormScreen.route());
        },
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
