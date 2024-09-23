import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:udetxen/features/home/services/home_service.dart';
import 'package:udetxen/features/trip/screens/trip_detail_screen.dart';
import 'package:udetxen/shared/types/models/trip.dart';

import 'package:udetxen/shared/widgets/loader.dart';

class AvailableToursWidget extends StatelessWidget {
  final HomeService homeService;

  const AvailableToursWidget({super.key, required this.homeService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Trip>>(
      stream: homeService.availableTours(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loading(isFullScreen: false);
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No available trips');
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
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        image: DecorationImage(
                          image: NetworkImage(
                              trip.destination?.imageUrls.first ?? ''),
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
    );
  }
}
