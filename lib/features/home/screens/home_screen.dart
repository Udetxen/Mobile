import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:udetxen/features/home/services/home_service.dart';
import 'package:udetxen/features/trip/screens/trip_detail_screen.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:udetxen/shared/types/models/trip.dart';
import 'package:udetxen/shared/types/models/venue.dart';

import 'package:udetxen/shared/widgets/layouts/authenticated_layout.dart';

class HomeScreen extends StatefulWidget {
  static route() {
    return MaterialPageRoute<void>(
      builder: (_) => getInstance(),
    );
  }

  static Widget getInstance() {
    return const AuthenticatedLayout();
  }

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeService _homeService = getIt<HomeService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Available Tours',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<Trip>>(
                stream: _homeService.availableTours(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No available tours');
                  }
                  return CarouselSlider(
                    options: CarouselOptions(
                      height: 200.0,
                      enlargeCenterPage: true,
                      autoPlay: true,
                    ),
                    items: snapshot.data!.map((trip) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  TripDetailScreen.route(trip.uid!),
                                );
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        trip.destination?.imageUrls.first ??
                                            ''),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.7),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Text(
                                        trip.name,
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 32),
              const Text(
                'Popular Venues',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<Venue>>(
                stream: _homeService.popularVenues(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No popular venues');
                  }
                  return Column(
                    children: snapshot.data!.map((venue) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              venue.name,
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            CarouselSlider(
                              options: CarouselOptions(
                                height: 150.0,
                                enlargeCenterPage: true,
                                autoPlay: true,
                              ),
                              items: venue.imageUrls.map((image) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          image: DecorationImage(
                                            image: NetworkImage(image),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
