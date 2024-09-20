import 'package:flutter/material.dart';
import 'package:udetxen/shared/types/models/trip.dart';

import '../screens/trip_detail_screen.dart';

class TripCard extends StatelessWidget {
  final Trip trip;

  const TripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: Theme.of(context).primaryColor, // Border color
          width: 2.0, // Border width
        ),
      ),
      child: InkWell(
        onTap: () {
          if (trip.uid != null) {
            Navigator.of(context)
                .push(TripDetailScreen.route(trip.uid as String));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (trip.departure != null &&
                  trip.departure!.imageUrls.isNotEmpty)
                _buildImageCarousel(
                    trip.departure!.imageUrls, 'From ${trip.departure!.name}'),
              if (trip.departure != null &&
                  trip.destination != null &&
                  trip.departure!.imageUrls.isNotEmpty &&
                  trip.destination!.imageUrls.isNotEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Icon(
                      Icons.arrow_downward,
                      color: Theme.of(context).primaryColor,
                      size: 24.0,
                    ),
                  ),
                ),
              if (trip.destination != null &&
                  trip.destination!.imageUrls.isNotEmpty)
                _buildImageCarousel(trip.destination!.imageUrls,
                    'To ${trip.destination!.name}'),
              const SizedBox(height: 16.0),
              Text(
                trip.name,
                style: Theme.of(context).textTheme.titleLarge,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8.0),
              Text(
                'Start Date: ${trip.startDate?.toLocal().toString().split(' ')[0] ?? 'N/A'}',
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Budget: \$${trip.budget.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel(List<String> imageUrls, String title) {
    return Container(
      height: 100.0, // Adjust the height based on your requirement
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Stack(
        children: [
          ListView.builder(
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
                        0.6, // Adjust width as needed
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: title.contains('From') ? 10.0 : null,
            top: title.contains('To') ? 10.0 : null,
            left: 10.0,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                title,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
