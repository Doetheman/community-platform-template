class Event {
  final String id;
  final String title;
  final DateTime dateTime;
  final String location;
  final String description;
  final bool isPaid;

  Event({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.location,
    required this.description,
    required this.isPaid,
  });
}
