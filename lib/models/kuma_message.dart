/// Categories for Kuma's messages
enum KumaMessageCategory {
  encouraging,
  motivational,
  playful,
  reaction,
  tutorial,
}

/// Kuma's mood / animation state
enum KumaMood {
  idle,
  happy,
  sad,
  celebrate,
  wave,
}

class KumaMessage {
  final String text;
  final KumaMessageCategory category;
  final KumaMood mood;

  const KumaMessage({
    required this.text,
    this.category = KumaMessageCategory.encouraging,
    this.mood = KumaMood.idle,
  });
}
