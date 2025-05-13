import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventFormState {
  final String title;
  final String location;
  final String description;
  final String price;
  final DateTime? date;
  final bool isPaid;

  EventFormState({
    this.title = '',
    this.location = '',
    this.description = '',
    this.price = '',
    this.date,
    this.isPaid = false,
  });

  EventFormState copyWith({
    String? title,
    String? location,
    String? description,
    String? price,
    DateTime? date,
    bool? isPaid,
  }) {
    return EventFormState(
      title: title ?? this.title,
      location: location ?? this.location,
      description: description ?? this.description,
      price: price ?? this.price,
      date: date ?? this.date,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}

class EventFormController extends StateNotifier<EventFormState> {
  EventFormController() : super(EventFormState());

  void updateTitle(String value) => state = state.copyWith(title: value);
  void updateLocation(String value) => state = state.copyWith(location: value);
  void updateDescription(String value) =>
      state = state.copyWith(description: value);
  void updatePrice(String value) => state = state.copyWith(price: value);
  void updateDate(DateTime date) => state = state.copyWith(date: date);
  void toggleIsPaid(bool value) => state = state.copyWith(isPaid: value);

  void reset() => state = EventFormState();
}

final eventFormControllerProvider =
    StateNotifierProvider<EventFormController, EventFormState>((ref) {
      return EventFormController();
    });
