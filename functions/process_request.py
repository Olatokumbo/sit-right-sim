import numpy as np
import scipy.ndimage

def process_data(backrest, seat):
    # Convert features to numpy array
    backrest = np.array(backrest)
    seat = np.array(seat)

    # Convert to numpy arrays
    # backrest = [np.array(subarray) for subarray in backrest]
    # seat = [np.array(subarray) for subarray in seat]

    # Ensure each subarray in backrest matches the corresponding one in seat
    if len(backrest) != len(seat):
        raise ValueError("Backrest and seat must have the same number of subarrays.")
    
    # elements_per_sensor = total_elements // num_sensors
    original_size = len(seat)
    
    # Split the input array into subarrays
    sensor_arrays = [backrest, seat]

    # Resize each subarray to 32x32 using bilinear interpolation
    resized_features = []
    for sensor_array in sensor_arrays:
        reshaped_array = np.reshape(sensor_array, (original_size, original_size))
        resized_array = scipy.ndimage.zoom(reshaped_array, (32 / original_size, 32 / original_size), order=1)
        resized_features.append(resized_array)

    return {
        "backrest": resized_features[0],
        "seat": resized_features[1]
    }