import 'package:cloud_functions/cloud_functions.dart';

final functions = FirebaseFunctions.instance;

Future<String> createStripeCheckoutSession({
  required String eventId,
  required String title,
  required double amount,
}) async {
  final callable = functions.httpsCallable('createCheckoutSession');
  final response = await callable.call({
    'eventId': eventId,
    'eventTitle': title,
    'amount': amount, // convert to cents
  });

  response.data['sessionUrl'];

  if (response.data['sessionUrl'] == null) {
    throw Exception('Failed to create checkout session');
  }

  return response.data['sessionUrl'];
}
