class PostureChart {
  final String posture;
  final int duration;

  PostureChart(this.posture, this.duration);

  PostureChart copyWith({String? posture, int? duration}) {
    return PostureChart(
      posture ?? this.posture,
      duration ?? this.duration,
    );
  }
}
