from firebase_functions import https_fn, options
import joblib
import numpy as np
import json
import scipy.ndimage

@https_fn.on_request(memory=options.MemoryOption.GB_1, cors=options.CorsOptions(cors_origins="*", cors_methods=["get", "post"]))
def main(req: https_fn.Request) -> https_fn.Response:
    if req.method == "POST":
        model = joblib.load('neural_network_32x32.pkl')
        print('Model loaded')
        data = req.json
        features = np.array(data['features'])
        
        # Calculate the number of sensors (2 in this case)
        num_sensors = 2
        # Determine the original size of each subarray
        total_elements = features.size
        elements_per_sensor = total_elements // num_sensors
        original_size = int(np.sqrt(elements_per_sensor))

        # Check if the elements_per_sensor forms a perfect square
        if original_size * original_size != elements_per_sensor:
            return https_fn.Response(
                json.dumps({'error': 'Input data does not form a square matrix'}),
                status=400,
                mimetype='application/json'
            )

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

        # Make a prediction
        prediction = model.predict([processed_features])
        print(prediction)

        # Convert the prediction to a JSON serializable format
        response_data = {'prediction': prediction.tolist()}

        return https_fn.Response(json.dumps(response_data), mimetype='application/json')

    return https_fn.Response('OK', status=200)