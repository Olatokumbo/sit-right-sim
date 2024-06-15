class PostureStatistics {
  final String posture;
  final Duration duration;

  PostureStatistics(this.posture, this.duration);

  PostureStatistics copyWith({String? posture, Duration? duration}) {
    return PostureStatistics(
      posture ?? this.posture,
      duration ?? this.duration,
    );
  }
}
