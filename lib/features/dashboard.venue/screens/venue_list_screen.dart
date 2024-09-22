import 'package:flutter/material.dart';
import 'package:udetxen/features/home/widgets/venue_detail.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:udetxen/shared/types/models/venue.dart';
import 'package:udetxen/shared/widgets/layouts/authenticated_layout.dart';

import '../services/dashboard_venue_service.dart';
import 'venue_form_screen.dart';

class VenueListScreen extends StatefulWidget {
  static route() {
    return MaterialPageRoute<void>(
      builder: (_) => getInstance(),
    );
  }

  static Widget getInstance() {
    return const AuthenticatedLayout(
      isAdmin: true,
      currentIndex: 1,
    );
  }

  const VenueListScreen({super.key});

  @override
  State<VenueListScreen> createState() => _VenueListScreenState();
}

class _VenueListScreenState extends State<VenueListScreen> {
  late Stream<List<Venue>> _venuesStream;

  @override
  void initState() {
    super.initState();
    _venuesStream = getIt<DashboardVenueService>().getVenues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Venues'),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<List<Venue>>(
          stream: _venuesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No venues found.'));
            } else {
              return ListView.separated(
                itemCount: snapshot.data!.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  color: Colors.grey,
                ),
                itemBuilder: (context, index) {
                  final venue = snapshot.data![index];
                  return VenueDetailWidget(
                    venue: venue,
                    allowActions: true,
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(VenueFormScreen.route());
        },
        backgroundColor: Theme.of(context).primaryColor,
        child:
            Icon(Icons.add, color: Theme.of(context).scaffoldBackgroundColor),
      ),
    );
  }
}
