class Event {
  final String id;
  final String title;
  final DateTime dateTime;
  final String location;
  final String description;
  final bool isPaid;
  final double? price;
  final String hostId;

  Event({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.location,
    required this.description,
    required this.isPaid,
    this.price,
    required this.hostId,
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
    );
  }
}
