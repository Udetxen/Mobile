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
      _selectedStatus = status == _selectedStatus ? null : status;
      _fetchTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              childAspectRatio: 3,
              mainAxisSpacing: 12.0,
              crossAxisSpacing: 12.0,
              children: TripStatus.values.map((TripStatus status) {
                String statusLabel = status.toString().split('.').last;
                switch (status) {
                  case TripStatus.active:
                    statusLabel = 'Active';
                    break;
                  case TripStatus.completed:
                    statusLabel = 'Completed';
                    break;
                  case TripStatus.notStarted:
                    statusLabel = 'Not Started';
                    break;
                }

                bool isSelected = _selectedStatus == status;

                return GestureDetector(
                  onTap: () {
                    _onStatusChanged(status);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).focusColor.withOpacity(0.2)
                          : Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Theme.of(context)
                            .focusColor
                            .withOpacity(isSelected ? 1.0 : 0.7),
                        width: 2.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Theme.of(context)
                                    .focusColor
                                    .withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w400,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8.0),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(TripFormScreen.route());
        },
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
