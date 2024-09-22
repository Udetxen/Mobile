import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:udetxen/features/dashboard.venue/screens/venue_form_screen.dart';
import 'package:udetxen/features/dashboard.venue/services/dashboard_venue_service.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:udetxen/shared/types/models/venue.dart';

class VenueDetailWidget extends StatefulWidget {
  final bool allowActions;
  final Venue venue;

  const VenueDetailWidget(
      {super.key, required this.venue, this.allowActions = false});

  @override
  State<VenueDetailWidget> createState() => _VenueDetailWidgetState();
}

class _VenueDetailWidgetState extends State<VenueDetailWidget> {
  bool _showActions = false;

  void _toggleActions() {
    if (!widget.allowActions) {
      return;
    }
    setState(() {
      _showActions = !_showActions;
    });
  }

  Future<void> _deleteVenue() async {
    final dashboardVenueService = getIt<DashboardVenueService>();
    await dashboardVenueService.deleteVenue(widget.venue.uid!);
  }

  void _updateVenue() {
    Navigator.of(context).push(VenueFormScreen.route(
      venueUid: widget.venue.uid!,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.venue.name,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _toggleActions,
            child: Stack(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 150.0,
                    enlargeCenterPage: true,
                    autoPlay: true,
                  ),
                  items: widget.venue.imageUrls.map((image) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
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
                if (_showActions)
                  Positioned.fill(
                    child: Container(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          ElevatedButton.icon(
                            onPressed: () {
                              _toggleActions();
                              _updateVenue();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 20.0),
                            ),
                            icon: const Icon(Icons.update,
                                color: Color.fromARGB(255, 79, 42, 42)),
                            label: const Text(
                              'Update',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16.0),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          ElevatedButton.icon(
                            onPressed: () {
                              _toggleActions();
                              // Confirm deletion
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Delete Image'),
                                    content: const Text(
                                        'Are you sure you want to delete this image?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Delete'),
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          await _deleteVenue();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 20.0),
                            ),
                            icon: const Icon(Icons.delete, color: Colors.white),
                            label: const Text(
                              'Delete',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
