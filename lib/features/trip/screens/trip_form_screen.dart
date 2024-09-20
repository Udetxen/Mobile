import 'package:flutter/material.dart';
import 'package:udetxen/features/auth/services/auth_service.dart';
import 'package:udetxen/features/trip/services/trip_service.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:udetxen/shared/types/models/trip.dart';
import 'package:udetxen/shared/types/models/venue.dart';
import 'package:udetxen/shared/utils/decor/input_decoration.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:udetxen/shared/types/models/user.dart';
import 'package:udetxen/shared/widgets/loader.dart';
import 'trip_detail_screen.dart';

class TripFormScreen extends StatefulWidget {
  final Trip? trip;

  static route({Trip? trip}) {
    return MaterialPageRoute<void>(
      builder: (_) => TripFormScreen(
        trip: trip,
      ),
    );
  }

  const TripFormScreen({super.key, this.trip});

  @override
  State<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends State<TripFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _startDateController = TextEditingController();
  final _durationController = TextEditingController();
  final _budgetController = TextEditingController();
  final _typeController = TextEditingController();
  Venue? _selectedDepartureVenue;
  Venue? _selectedDestinationVenue;
  List<User> _selectedParticipants = [];

  late Future<List<Venue>> _venueFuture;
  late Future<List<User>> _userFuture;

  final _searchController = TextEditingController();

  final TripService _tripService = getIt<TripService>();
  final AuthService _authService = getIt<AuthService>();

  @override
  void initState() {
    super.initState();
    if (widget.trip != null) {
      _nameController.text = widget.trip!.name;
      _startDateController.text = widget.trip?.startDate.toString() ?? '';
      _durationController.text = widget.trip!.duration.toString();
      _budgetController.text = widget.trip!.budget.toString();
      _typeController.text = widget.trip!.type;
      _selectedDepartureVenue = widget.trip!.departure;
      _selectedDestinationVenue = widget.trip!.destination;
      _selectedParticipants = [];
    }
    _venueFuture = _tripService.getVenues().first;
    _userFuture = _tripService.getUsers(widget.trip?.uid ?? '').first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startDateController.dispose();
    _durationController.dispose();
    _budgetController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  void _onSearch() {
    setState(() {
      _venueFuture = _tripService
          .getVenues(
            name: _searchController.text.trim(),
          )
          .first;
    });
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

  Widget _buildParticipantSelector() {
    return FutureBuilder<List<User>>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error fetching users');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No users available');
        }

        final users = snapshot.data!
            .where((u) => u.uid != _authService.currentUserUid)
            .toList();

        return MultiSelectDialogField<User>(
          itemsTextStyle: TextStyle(color: Theme.of(context).primaryColor),
          selectedItemsTextStyle:
              TextStyle(color: Theme.of(context).focusColor),
          items: users
              .map(
                  (user) => MultiSelectItem<User>(user, user.displayName ?? ''))
              .toList(),
          title: const Text('Select Participants'),
          selectedColor: Theme.of(context).focusColor,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(
              color: Colors.grey,
              width: 1,
            ),
          ),
          buttonIcon: const Icon(
            Icons.group,
            color: Colors.grey,
          ),
          buttonText: const Text(
            'Select Participants',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          onConfirm: (results) {
            setState(() {
              _selectedParticipants = results;
            });
          },
          initialValue: _selectedParticipants,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Form'),
        backgroundColor: Theme.of(context).hintColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: getInputDecoration(context, labelText: 'Trip Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a trip name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _startDateController,
                decoration:
                    getInputDecoration(context, labelText: 'Start Date'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a start date';
                  }
                  return null;
                },
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      _startDateController.text =
                          pickedDate.toLocal().toString().split(' ')[0];
                    });
                  }
                },
              ),
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
              DropdownButtonFormField<String>(
                value:
                    _typeController.text.isEmpty ? null : _typeController.text,
                decoration: getInputDecoration(context,
                    labelText: 'Type (individual/group)'),
                items: ['individual', 'group'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _typeController.text = newValue!;
                    if (newValue == 'group') {
                      _userFuture =
                          _tripService.getUsers(widget.trip?.uid ?? '').first;
                    }
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select the type';
                  }
                  return null;
                },
              ),
              if (_typeController.text == 'group') _buildParticipantSelector(),
              const SizedBox(height: 20),
              _buildVenueDropdown(
                label: 'Departure Venue',
                selectedVenue: _selectedDepartureVenue,
                onChanged: (venue) {
                  setState(() {
                    _selectedDepartureVenue = venue;
                  });
                },
              ),
              const SizedBox(height: 20),
              _buildVenueDropdown(
                label: 'Destination Venue',
                selectedVenue: _selectedDestinationVenue,
                onChanged: (venue) {
                  setState(() {
                    _selectedDestinationVenue = venue;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final newTripUid = widget.trip == null
                        ? await _tripService.createTrip(Trip(
                            name: _nameController.text,
                            startDate:
                                DateTime.parse(_startDateController.text),
                            duration: int.parse(_durationController.text),
                            budget: double.parse(_budgetController.text),
                            type: _typeController.text,
                            departureUid: _selectedDepartureVenue!.uid!,
                            destinationUid: _selectedDestinationVenue!.uid!,
                            participants: _selectedParticipants.isNotEmpty
                                ? _selectedParticipants
                                    .map((u) =>
                                        Participant(participantUid: u.uid!))
                                    .toList()
                                : null,
                          ))
                        : await _tripService
                            .updateForkedTrip(widget.trip!.copyWith(
                            uid: widget.trip!.uid,
                            name: _nameController.text,
                            startDate:
                                DateTime.parse(_startDateController.text),
                            duration: int.parse(_durationController.text),
                            budget: double.parse(_budgetController.text),
                            type: _typeController.text,
                            departureUid: _selectedDepartureVenue!.uid!,
                            destinationUid: _selectedDestinationVenue!.uid!,
                            participants: _selectedParticipants
                                .map((u) => Participant(participantUid: u.uid!))
                                .toList(),
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
    );
  }
}
