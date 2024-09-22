class Venue {
  String? uid;
  String name;
  List<String> imageUrls;

  Venue({
    this.uid,
    required this.name,
    required this.imageUrls,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      uid: json['uid'],
      name: json['name'],
      imageUrls: List<String>.from(json['imageUrls']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'imageUrls': imageUrls,
    };
  }

  Venue copyWith({
    String? uid,
    String? name,
    List<String>? imageUrls,
  }) {
    return Venue(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }
}
