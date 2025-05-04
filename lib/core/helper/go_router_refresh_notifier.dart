import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(AsyncValue value) {
    notifyListeners(); // call once immediately
    _listen(value);
  }

  void _listen(AsyncValue value) {
    value.whenOrNull(
      data: (_) => notifyListeners(),
      error: (_, __) => notifyListeners(),
      loading: () {}, // don't notify on loading
    );
  }
}
