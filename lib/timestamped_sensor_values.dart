class TimeStampedSensorValues {
  final DateTime timestamp;
  final List<List<double>> sensorValues;

  TimeStampedSensorValues({
    required this.timestamp,
    required this.sensorValues,
  });
}
