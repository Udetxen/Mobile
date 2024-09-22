import 'package:flutter/material.dart';
import 'package:udetxen/features/home/services/home_service.dart';
import 'package:udetxen/shared/types/models/venue.dart';

import 'package:udetxen/shared/widgets/loader.dart';

import 'venue_detail.dart';

class PopularVenuesWidget extends StatelessWidget {
  final HomeService homeService;

  const PopularVenuesWidget({super.key, required this.homeService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Venue>>(
      stream: homeService.popularVenues(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loading(isFullScreen: false);
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No popular venues');
        }
        return Column(
          children: snapshot.data!.map((venue) {
            return VenueDetailWidget(venue: venue);
          }).toList(),
        );
      },
    );
  }
}
