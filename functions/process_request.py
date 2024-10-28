import numpy as np
import scipy.ndimage

def process_data(features):
    # Convert features to numpy array
    features = np.array(features)

    # Number of sensors (you can make this dynamic if needed)
    num_sensors = 2

    # Calculate the size of the subarrays
    total_elements = features.size
    elements_per_sensor = total_elements // num_sensors
    original_size = int(np.sqrt(elements_per_sensor))

    # Check if elements form a perfect square
    if original_size * original_size != elements_per_sensor:
        return None

    # Split the input array into subarrays
    sensor_arrays = np.split(features, num_sensors)

    # Resize each subarray to 32x32 using bilinear interpolation
    resized_features = []
    for sensor_array in sensor_arrays:
        reshaped_array = np.reshape(sensor_array, (original_size, original_size))
        resized_array = scipy.ndimage.zoom(reshaped_array, (32 / original_size, 32 / original_size), order=1)
        resized_features.append(resized_array.flatten())

    # Combine the resized features into one array
    processed_features = np.concatenate(resized_features)

    return processed_features