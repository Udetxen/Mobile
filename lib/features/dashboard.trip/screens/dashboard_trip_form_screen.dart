import 'package:flutter/material.dart';
import 'package:udetxen/features/trip/screens/trip_detail_screen.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:udetxen/shared/types/models/trip.dart';
import 'package:udetxen/shared/types/models/venue.dart';
import 'package:udetxen/shared/utils/decor/input_decoration.dart';
import 'package:udetxen/shared/widgets/loader.dart';

import '../services/dashboard_trip_service.dart';

class DashboardTripFormScreen extends StatefulWidget {
  final Trip? trip;

  static route({Trip? trip}) {
    return MaterialPageRoute<void>(
      builder: (_) => DashboardTripFormScreen(
        trip: trip,
      ),
    );
  }

  const DashboardTripFormScreen({super.key, this.trip});

  @override
  State<DashboardTripFormScreen> createState() =>
      _DashboardTripFormScreenState();
}

class _DashboardTripFormScreenState extends State<DashboardTripFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  final _budgetController = TextEditingController();
  final _typeController = TextEditingController();
  Venue? _selectedDepartureVenue;
  Venue? _selectedDestinationVenue;

  late Future<List<Venue>> _venueFuture;

  final DashboardTripService _dashboardTripService =
      getIt<DashboardTripService>();

  @override
  void initState() {
    super.initState();
    if (widget.trip != null) {
      _nameController.text = widget.trip!.name;

      _durationController.text = widget.trip!.duration.toString();
      _budgetController.text = widget.trip!.budget.toString();
      _typeController.text = widget.trip!.type;
      _selectedDepartureVenue = widget.trip!.departure;
      _selectedDestinationVenue = widget.trip!.destination;
    }
    _venueFuture = _dashboardTripService.getVenues().first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _budgetController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  Widget _buildVenueDropdown(
      {required String label,
      Venue? selectedVenue,
      required void Function(Venue?) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<List<Venue>>(
          future: _venueFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Error fetching venues');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loading();
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No venues available');
            }

            final venues = snapshot.data!;
            final defaultSelectedVenue = venues.firstWhere(
              (venue) => venue.uid == selectedVenue?.uid,
              orElse: () => Venue(name: "", imageUrls: []),
            );

            return DropdownButtonFormField<Venue>(
              decoration: getInputDecoration(context, labelText: label),
              value: defaultSelectedVenue.uid == null
                  ? null
                  : defaultSelectedVenue,
              items: venues.map((venue) {
                return DropdownMenuItem<Venue>(
                  value: venue,
                  child: Row(
                    children: [
                      if (venue.imageUrls.isNotEmpty)
                        Image.network(
                          venue.imageUrls.first,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      const SizedBox(width: 10),
                      Text(venue.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              validator: (value) {
                if (value == null) {
                  return 'Please select a venue';
                }
                return null;
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Form'),
        backgroundColor: Theme.of(context).hintColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration:
                      getInputDecoration(context, labelText: 'Trip Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a trip name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _durationController,
                  decoration:
                      getInputDecoration(context, labelText: 'Duration (days)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the duration';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _budgetController,
                  decoration: getInputDecoration(context, labelText: 'Budget'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a budget';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _typeController.text.isEmpty
                      ? null
                      : _typeController.text,
                  decoration: getInputDecoration(context,
                      labelText: 'Type (individual/group)'),
                  items: ['individual', 'group'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _typeController.text = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select the type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildVenueDropdown(
                  label: 'Departure Venue',
                  selectedVenue: _selectedDepartureVenue,
                  onChanged: (venue) {
                    setState(() {
                      _selectedDepartureVenue = venue;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildVenueDropdown(
                  label: 'Destination Venue',
                  selectedVenue: _selectedDestinationVenue,
                  onChanged: (venue) {
                    setState(() {
                      _selectedDestinationVenue = venue;
                    });
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final newTripUid = await _dashboardTripService
                          .createOrUpdateAvailableTrip(Trip(
                        uid: widget.trip?.uid,
                        name: _nameController.text,
                        duration: int.parse(_durationController.text),
                        budget: double.parse(_budgetController.text),
                        type: _typeController.text,
                        departureUid: _selectedDepartureVenue!.uid!,
                        destinationUid: _selectedDestinationVenue!.uid!,
                      ));

                      Navigator.of(context)
                          .pushReplacement(TripDetailScreen.route(newTripUid));
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
