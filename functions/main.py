from firebase_functions import https_fn, options
from process_request import process_data
from model import load_model, make_prediction
from hausdorff import calculate_hausdorff, calculate_weighted_hausdorff
import json
import numpy as np

@https_fn.on_request(memory=options.MemoryOption.GB_1, cors=options.CorsOptions(cors_origins="*", cors_methods=["get", "post"]))
def main(req: https_fn.Request) -> https_fn.Response:
    if req.method == "POST":
        try:
            data = req.json
            features = data['features']
        except KeyError:
            return https_fn.Response(
                json.dumps({'error': 'Invalid input data format'}),
                status=400,
                mimetype='application/json'
            )

        # Process the data (resize and transform)
        processed_features = process_data(features)
        if processed_features is None:
            return https_fn.Response(
                json.dumps({'error': 'Input data does not form a square matrix'}),
                status=400,
                mimetype='application/json'
            )

        # Load the model and make prediction
        model = load_model('neural_network_32x32.pkl')
        prediction = make_prediction(model, processed_features)

        # Return the response
        response_data = {'prediction': prediction.tolist()}
        return https_fn.Response(json.dumps(response_data), mimetype='application/json')

    return https_fn.Response('OK', status=200)


@https_fn.on_request(memory=options.MemoryOption.GB_1, cors=options.CorsOptions(cors_origins="*", cors_methods=["get", "post"]))
def hausdorff_distance(req: https_fn.Request) -> https_fn.Response:
    if req.method == "POST":
        data = req.json
        upright_backrest = np.array(data['upright_backrest'])
        upright_seat = np.array(data['upright_seat'])
        posture_backrest = np.array(data['posture_backrest'])
        posture_seat = np.array(data['posture_seat'])

        # Calculate Hausdorff distances between pairs
        hausdorff_backrest = calculate_hausdorff(upright_backrest, posture_backrest)
        hausdorff_seat = calculate_hausdorff(upright_seat, posture_seat)
        
        weight_hausdorff_backrest = calculate_weighted_hausdorff(upright_backrest, posture_backrest)
        weight_hausdorff_seat = calculate_weighted_hausdorff(upright_seat, posture_seat)

        # Response data with both Hausdorff distances
        response_data = {
            'hausdorff_backrest': hausdorff_backrest,
            'hausdorff_seat': hausdorff_seat,
            'weighted_hausdorff_backrest': weight_hausdorff_backrest,
            'weighted_hausdorff_seat': weight_hausdorff_seat,
        }

        return https_fn.Response(json.dumps(response_data), mimetype='application/json')

    return https_fn.Response('OK', status=200)
