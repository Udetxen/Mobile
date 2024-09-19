import 'package:flutter/material.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:udetxen/shared/types/models/trip.dart';
import 'package:udetxen/shared/widgets/layouts/authenticated_layout.dart';
import 'package:udetxen/shared/widgets/loader.dart';

import '../models/trip_status.dart';
import '../services/trip_service.dart';
import '../widgets/trip_card.dart';
import 'trip_form_screen.dart';

class TripListScreen extends StatefulWidget {
  static route() {
    return MaterialPageRoute<void>(
      builder: (_) => getInstance(),
    );
  }

  static Widget getInstance() {
    return const AuthenticatedLayout(
      currentIndex: 1,
    );
  }

  const TripListScreen({super.key});

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  late Future<Stream<List<Trip>>> _tripsFuture;
  TripStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _fetchTrips();
  }

  void _fetchTrips() {
    _tripsFuture = getIt<TripService>().getUserTrips(status: _selectedStatus);
  }

  void _onStatusChanged(TripStatus? status) {
    setState(() {
      _selectedStatus = status;
      _fetchTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<TripStatus?>(
                  hint: const Text('Select Trip Status'),
                  value: _selectedStatus,
                  onChanged: _onStatusChanged,
                  items: [
                    const DropdownMenuItem<TripStatus?>(
                      value: null,
                      child: Text('All'),
                    ),
                    ...TripStatus.values.map((TripStatus status) {
                      return DropdownMenuItem<TripStatus?>(
                        value: status,
                        child: Text(status.toString().split('.').last),
                      );
                    }),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.of(context).push(TripFormScreen.route());
                },
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<Stream<List<Trip>>>(
              future: _tripsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loading();
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text('No trips found.'));
                } else {
                  return StreamBuilder<List<Trip>>(
                    stream: snapshot.data,
                    builder: (context, streamSnapshot) {
                      if (streamSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Loading();
                      } else if (streamSnapshot.hasError) {
                        return Center(
                            child: Text('Error: ${streamSnapshot.error}'));
                      } else if (!streamSnapshot.hasData ||
                          streamSnapshot.data!.isEmpty) {
                        return const Center(child: Text('No trips found.'));
                      } else {
                        return ListView.builder(
                          itemCount: streamSnapshot.data!.length,
                          itemBuilder: (context, index) {
                            final trip = streamSnapshot.data![index];
                            return TripCard(trip: trip);
                          },
                        );
                      }
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
