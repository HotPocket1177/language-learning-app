/// Kuma's emotion / animation state
enum KumaEmotion {
  idle,         // subtle breathing (scale 1.0 ↔ 1.02, 2s loop)
  happy,        // bounce animation (up/down 10px, 0.5s)
  excited,      // jump animation (up 20px, faster bounce)
  celebrating,  // spin 360° + scale pulse
  encouraging,  // gentle nod (rotate ±5°)
  sad,          // slow droop (opacity 0.7, move down 5px)
}

/// Categories for Kuma's messages
enum KumaMessageCategory {
  encouraging,
  motivational,
  playful,
  reaction,
  tutorial,
}

class KumaMessage {
  final String text;
  final KumaMessageCategory category;
  final KumaEmotion emotion;

  const KumaMessage({
    required this.text,
    this.category = KumaMessageCategory.encouraging,
    this.emotion = KumaEmotion.idle,
  });
}
