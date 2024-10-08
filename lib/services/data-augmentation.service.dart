import 'dart:math';

class DataAugmentationService {
  // Add Noise to the Data
  List<List<double>> _addNoise(List<List<double>> data,
      {double noiseLevel = 25.5}) {
    var random = Random();
    return data.map((row) {
      return row.map((val) {
        return (val + random.nextDouble() * noiseLevel * 2 - noiseLevel)
            .clamp(0.0, 255.0);
      }).toList();
    }).toList();
  }

  // Scale the Data
  List<List<double>> _scaleData(List<List<double>> data,
      {double scaleFactor = 0.1}) {
    var random = Random();
    double scale = 1 + (random.nextDouble() * scaleFactor * 2 - scaleFactor);
    return data.map((row) {
      return row.map((val) {
        return (val * scale).clamp(0.0, 255.0);
      }).toList();
    }).toList();
  }

  // Shift the Data (Not in use)
  List<List<double>> _shiftData(List<List<double>> data, {int shiftMax = 0}) {
    var random = Random();
    int shiftX = random.nextInt(shiftMax * 2 + 1) - shiftMax;
    int shiftY = random.nextInt(shiftMax * 2 + 1) - shiftMax;

    List<List<double>> shiftedData = List.generate(
        data.length, (_) => List<double>.filled(data[0].length, 0));
    for (int i = 0; i < data.length; i++) {
      for (int j = 0; j < data[0].length; j++) {
        int newX = (i + shiftX) % data.length;
        int newY = (j + shiftY) % data[0].length;
        if (newX < 0) newX += data.length;
        if (newY < 0) newY += data[0].length;
        shiftedData[newX][newY] = data[i][j];
      }
    }
    return shiftedData;
  }

  // Rotate the Data
  List<List<double>> _rotateData(List<List<double>> data,
      {double maxAngle = pi / 10}) {
    var random = Random();
    double angle = (random.nextDouble() * 2 - 1) * maxAngle; // Random angle

    int height = data.length;
    int width = data[0].length;
    List<List<double>> rotatedData =
        List.generate(height, (_) => List<double>.filled(width, 0.0));

    int centerX = height ~/ 2;
    int centerY = width ~/ 2;

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        int x = i - centerX;
        int y = j - centerY;

        int newX = (x * cos(angle) - y * sin(angle)).round() + centerX;
        int newY = (x * sin(angle) + y * cos(angle)).round() + centerY;

        if (newX >= 0 && newX < height && newY >= 0 && newY < width) {
          rotatedData[newX][newY] = data[i][j];
        }
      }
    }

    return rotatedData;
  }

  // Adjust Brightness
  List<List<double>> _adjustBrightness(List<List<double>> data,
      {double factor = 1.5}) {
    return data.map((row) {
      return row.map((val) {
        return (val * factor).clamp(0.0, 255.0);
      }).toList();
    }).toList();
  }

  // Adjust Contrast
  List<List<double>> _adjustContrast(List<List<double>> data,
      {double factor = 1.5}) {
    double mean = data.expand((i) => i).reduce((a, b) => a + b) /
        (data.length * data[0].length);
    return data.map((row) {
      return row.map((val) {
        return ((val - mean) * factor + mean).clamp(0.0, 255.0);
      }).toList();
    }).toList();
  }

  // Clip Data
  List<List<double>> _clipData(List<List<double>> data,
      {double minValue = 0.0, double maxValue = 255.0}) {
    return data.map((row) {
      return row.map((val) {
        return val.clamp(minValue, maxValue);
      }).toList();
    }).toList();
  }

  // Apply Gaussian Blur (placeholder)
  List<List<double>> _applyGaussianBlur(List<List<double>> data,
      {double sigma = 1}) {
    // Add implementation for Gaussian blur here
    return data;
  }

  // Random Erasing (placeholder)
  List<List<double>> _randomErasing(List<List<double>> data,
      {double eraseProb = 0.5, double eraseSize = 0.1}) {
    // Add implementation for random erasing here
    return data;
  }

  // Generate Augmented Data for a Given Posture
  List<List<double>> generateAugmentedDataForPosture(List<List<double>> data) {
    var random = Random();
    var augData =
        List<List<double>>.from(data.map((row) => List<double>.from(row)));

    if (random.nextBool()) augData = _addNoise(augData);
    if (random.nextBool()) augData = _scaleData(augData);
    if (random.nextBool()) augData = _shiftData(augData); // Removed for now
    if (random.nextBool()) augData = _rotateData(augData);
    if (random.nextBool()) augData = _applyGaussianBlur(augData);
    if (random.nextBool()) augData = _randomErasing(augData);
    if (random.nextBool()) augData = _adjustBrightness(augData);
    if (random.nextBool()) augData = _adjustContrast(augData);
    if (random.nextBool()) augData = _clipData(augData);

    return augData;
  }
}