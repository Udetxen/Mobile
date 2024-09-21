import 'package:flutter/material.dart';

class TripDetailImageCard extends StatelessWidget {
  final List<String> imageUrls;
  final String title;
  final String locationName;

  const TripDetailImageCard({
    super.key,
    required this.imageUrls,
    required this.title,
    required this.locationName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageCarousel(imageUrls, title),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Location: $locationName',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(8.0),
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
