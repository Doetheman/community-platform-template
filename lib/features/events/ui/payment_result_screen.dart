import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:white_label_community_app/features/events/state/event_provider.dart';

// Define provider to track payment status
final paymentStatusProvider = StateProvider<String?>((ref) => null);

class PaymentResultScreen extends ConsumerWidget {
  final String eventId;
  final bool isSuccess;
  final String? sessionId;

  const PaymentResultScreen({
    super.key,
    required this.eventId,
    required this.isSuccess,
    this.sessionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref.watch(eventByIdProvider(eventId));
    final paymentStatus = ref.watch(paymentStatusProvider);

    // Check payment status on first load
    if (paymentStatus == null && isSuccess && sessionId != null) {
      _verifyPayment(context, ref);
    }

    if (paymentStatus == 'pending') {
      return Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Verifying payment... hang tight.'),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Result'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSuccess) ...[
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 100,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Payment Successful!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                event.when(
                  data:
                      (eventData) => Text(
                        'Thank you for purchasing a ticket to ${eventData.title}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18),
                      ),
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const Text('Event details not available'),
                ),
                const SizedBox(height: 8),
                const Text(
                  'An email confirmation will be sent shortly with your ticket details.',
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                const Icon(Icons.cancel_outlined, color: Colors.red, size: 100),
                const SizedBox(height: 24),
                const Text(
                  'Payment Canceled',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                event.when(
                  data:
                      (eventData) => Text(
                        'You have not been charged for ${eventData.title}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18),
                      ),
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const Text('Event details not available'),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Navigate to event details
                  event.whenData((eventData) {
                    context.push('/event/${eventData.id}', extra: eventData);
                  });
                },
                child: const Text('View Event Details'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('Return to Events'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyPayment(BuildContext context, WidgetRef ref) async {
    ref.read(paymentStatusProvider.notifier).state = 'checking';

    try {
      // Check if payment was successful by looking at the RSVP record
      final firestore = FirebaseFirestore.instance;
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) {
        ref.read(paymentStatusProvider.notifier).state = 'error';
        return;
      }

      final rsvpDoc =
          await firestore
              .collection('events')
              .doc(eventId)
              .collection('rsvps')
              .doc(uid)
              .get();

      if (rsvpDoc.exists && rsvpDoc.data()?['paid'] == true) {
        ref.read(paymentStatusProvider.notifier).state = 'success';
      } else {
        // This may happen if the webhook hasn't processed yet
        if (!rsvpDoc.exists || rsvpDoc.data()?['paid'] != true) {
          for (int i = 0; i < 3; i++) {
            await Future.delayed(Duration(seconds: 2));
            final retryDoc =
                await firestore
                    .collection('events')
                    .doc(eventId)
                    .collection('rsvps')
                    .doc(uid)
                    .get();
            if (retryDoc.exists && retryDoc.data()?['paid'] == true) {
              ref.read(paymentStatusProvider.notifier).state = 'success';
              return;
            }
          }
          ref.read(paymentStatusProvider.notifier).state = 'pending';
        }
      }
    } catch (e) {
      ref.read(paymentStatusProvider.notifier).state = 'error';
    }
  }
}
