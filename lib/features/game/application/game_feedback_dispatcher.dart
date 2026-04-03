import 'dart:async';

import 'package:flutter/services.dart';

class GameFeedbackDispatcher {
  const GameFeedbackDispatcher();

  void onRoundStart() {
    _emitAudioHook('round_start');
  }

  void onLock() {
    _emitAudioHook('lock');
  }

  void onAnnihilation() {
    _emitAudioHook('annihilation');
    _tryHaptic(HapticFeedback.mediumImpact);
  }

  void onRoundEnd({required bool success}) {
    _emitAudioHook('round_end');
    if (!success) {
      _tryHaptic(HapticFeedback.heavyImpact);
    }
  }

  void _emitAudioHook(String eventName) {
    // TODO(v9): Replace stub event hooks with browser-safe SFX playback.
    if (eventName.isEmpty) {
      return;
    }
  }

  void _tryHaptic(Future<void> Function() action) {
    unawaited(_safeHaptic(action));
  }

  Future<void> _safeHaptic(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      // Web and desktop builds may not support haptics. Fail silently.
    }
  }
}
