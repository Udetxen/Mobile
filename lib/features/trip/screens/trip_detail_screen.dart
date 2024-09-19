import 'package:flutter/material.dart';
import 'package:udetxen/features/trip/screens/trip_form_screen.dart';
import 'package:udetxen/features/trip/services/trip_service.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:udetxen/shared/types/models/trip.dart';

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
          final participation =
              trip.participants != null && trip.participants?.isNotEmpty == true
                  ? trip.participants
                      ?.firstWhere((p) => p.participantUid == trip.creator?.uid)
                  : null;
          final totalExpense = trip.expenses?.fold<double>(
            0.0,
            (previousValue, element) => previousValue + element.expense!,
          );

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Trip Name and Action Button
              Row(
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
                  ElevatedButton(
                    onPressed: () async {
                      final forkedTrip = await _tripService.forkTrip(trip);

                      Navigator.of(context).pushReplacement(
                        TripFormScreen.route(trip: forkedTrip),
                      );
                    },
                    child: const Text('Make a Plan'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Budget: \$${trip.budget.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      if (totalExpense != null) ...[
                        Text(
                          'Total Expense: \$${totalExpense.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('View Expenses'),
                        ),
                      ] else ...[
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Add Expense'),
                        ),
                      ],
                      Text(
                        'Start Date: ${trip.startDate?.toLocal().toString().split(' ')[0] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Duration: ${trip.duration} days',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        trip.type,
                        style: const TextStyle(fontSize: 18),
                      ),
                      if (trip.type == 'group' &&
                          participation?.personalBudget == null)
                        ElevatedButton(
                            onPressed: () {},
                            child: const Text('create your personal budget'))
                    ],
                  ),
                ),
              ),

              // Departure Images
              if (trip.departure.imageUrls.isNotEmpty)
                Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  elevation: 4.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageCarousel(trip.departure.imageUrls,
                          'From ${trip.departure.name}'),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Departure: ${trip.departure.name}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),

              // Destination Images
              if (trip.destination.imageUrls.isNotEmpty)
                Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  elevation: 4.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageCarousel(trip.destination.imageUrls,
                          'To ${trip.destination.name}'),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Destination: ${trip.destination.name}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),

              // Additional Trip Details
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageCarousel(List<String> imageUrls, String title) {
    return Container(
      height: 200.0, // Adjust height as needed
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      imageUrls[index],
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width *
                          0.8, // Adjust width as needed
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
