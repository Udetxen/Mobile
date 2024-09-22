import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:udetxen/shared/types/models/venue.dart';
import 'package:udetxen/shared/utils/decor/input_decoration.dart';

import '../services/dashboard_venue_service.dart';

class VenueFormScreen extends StatefulWidget {
  final String? venueUid;

  static route({String? venueUid}) {
    return MaterialPageRoute<void>(
      builder: (_) => VenueFormScreen(venueUid: venueUid),
    );
  }

  const VenueFormScreen({super.key, this.venueUid});

  @override
  State<VenueFormScreen> createState() => _VenueFormScreenState();
}

class _VenueFormScreenState extends State<VenueFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  List<String> _imageUrls = [];
  final List<File> _imageFiles = [];
  bool _isSubmitting = false;
  Venue? _venue;
  StreamSubscription<Venue>? _venueSubscription;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();

    if (widget.venueUid != null) {
      _venueSubscription = getIt<DashboardVenueService>()
          .getVenue(widget.venueUid!)
          .listen((venue) {
        setState(() {
          _venue = venue;
          _nameController.text = venue.name;
          _imageUrls = venue.imageUrls;
        });
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _venueSubscription?.cancel();
    super.dispose();
  }

  void _pickImage() async {
    if (_formKey.currentState?.validate() == true && _venue != null) {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFiles.add(File(pickedFile.path));
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please save the venue first!')),
      );
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (!mounted)
        return; // Ensure widget is still mounted before calling setState
      setState(() {
        _isSubmitting = true;
      });

      try {
        final venueService = getIt<DashboardVenueService>();
        Venue venue = _venue?.copyWith(name: _nameController.text) ??
            Venue(name: _nameController.text, imageUrls: []);

        if (_venue == null) {
          final newVenue = await venueService.addVenue(venue);
          if (mounted) {
            Navigator.of(context)
                .pushReplacement(VenueFormScreen.route(venueUid: newVenue.uid));
          }
        } else {
          await venueService.updateVenue(venue);
          if (mounted) {
            Navigator.of(context).pop();
          }
        }

        if (_imageFiles.isNotEmpty) {
          final venueId = _venue?.uid;
          for (var imageFile in _imageFiles) {
            await venueService.uploadVenueImage(venueId!, imageFile);
          }
          if (mounted) {
            setState(() {
              _imageFiles.clear();
            });
          }
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  void _removeImage(String imageUrl) async {
    final venueService = getIt<DashboardVenueService>();
    await venueService.deleteVenueImage(_venue!.uid!, imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_venue == null ? 'Add Venue' : 'Edit Venue'),
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
                if (widget.venueUid != null)
                  _buildImageGrid(
                    context,
                    images: _imageUrls,
                    newImages: _imageFiles.map((file) => file.path).toList(),
                    onRemove: (imageUrl) => _removeImage(imageUrl),
                  ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _nameController,
                  decoration:
                      getInputDecoration(context, labelText: 'Venue Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a venue name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () async =>
                        _isSubmitting ? null : await _submit(),
                    child: _isSubmitting
                        ? const CircularProgressIndicator()
                        : Text('${_venue == null ? 'Add' : 'Save'} Venue'),
                  ),
                ),
                const SizedBox(height: 48.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context,
      {required List<String> images,
      required List<String> newImages,
      required Function(String) onRemove}) {
    final totalImages = images.length + newImages.length;
    return SizedBox(
      height:
          totalImages == 0 ? 130.0 : 130.0 * (((totalImages + 1) / 3).ceil()),
      child: totalImages == 0
          ? Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo,
                      size: 40.0,
                      color: Theme.of(context).primaryColor,
                    ),
                    Text(
                      'Select',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: totalImages + 1,
              itemBuilder: (context, index) {
                final lastIndex = index == totalImages;
                final isCurrentImages = index < images.length;
                final imageUrl = isCurrentImages
                    ? images[index]
                    : !lastIndex
                        ? newImages[index - images.length]
                        : '';
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: imageUrl == ''
                              ? Theme.of(context).primaryColor
                              : isCurrentImages
                                  ? Colors.green
                                  : Colors.orange,
                          width: 2.0,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: imageUrl == ''
                            ? Container(
                                color: Theme.of(context)
                                    .scaffoldBackgroundColor
                                    .withOpacity(0.5),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: _pickImage,
                                        child: Icon(
                                          Icons.add_a_photo,
                                          size: 40.0,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      Text(
                                        'Select',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : isCurrentImages
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  )
                                : Image.file(
                                    File(imageUrl),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                      ),
                    ),
                    if (imageUrl != '')
                      Positioned(
                        top: 4.0,
                        right: 4.0,
                        child: GestureDetector(
                          onTap: () => isCurrentImages
                              ? onRemove(imageUrl)
                              : setState(() {
                                  _imageFiles.removeAt(index - images.length);
                                }),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }
}
