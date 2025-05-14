class Event {
  final String id;
  final String title;
  final DateTime dateTime;
  final String location;
  final String description;
  final bool isPaid;
  final double? price;
  final String hostId;
  final int capacity;
  final String? imageUrl;
  final List<String>? galleryImageUrls;
  final String? category;
  final Map<String, dynamic>? additionalInfo;

  Event({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.location,
    required this.description,
    required this.isPaid,
    this.price,
    required this.hostId,
    required this.capacity,
    this.imageUrl,
    this.galleryImageUrls,
    this.category,
    this.additionalInfo,
  });

  Event copyWith({
    String? id,
    String? title,
    DateTime? dateTime,
    String? location,
    String? description,
    bool? isPaid,
    double? price,
    String? hostId,
    int? capacity,
    String? imageUrl,
    List<String>? galleryImageUrls,
    String? category,
    Map<String, dynamic>? additionalInfo,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      description: description ?? this.description,
      isPaid: isPaid ?? this.isPaid,
      price: price ?? this.price,
      hostId: hostId ?? this.hostId,
      capacity: capacity ?? this.capacity,
      imageUrl: imageUrl ?? this.imageUrl,
      galleryImageUrls: galleryImageUrls ?? this.galleryImageUrls,
      category: category ?? this.category,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
}
