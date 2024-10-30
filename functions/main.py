from firebase_functions import https_fn, options
from process_request import process_data
from model import load_model, make_prediction
from hausdorff import calculate_hausdorff, calculate_weighted_hausdorff
from scipy.spatial import procrustes
import json
import numpy as np

@https_fn.on_request(memory=options.MemoryOption.GB_1, cors=options.CorsOptions(cors_origins="*", cors_methods=["get", "post"]))
def main(req: https_fn.Request) -> https_fn.Response:
    if req.method == "POST":
        try:
            data = req.json
            backrest = np.array(data['posture_backrest'])
            seat = np.array(data['posture_seat'])
        except KeyError:
            return https_fn.Response(
                json.dumps({'error': 'Invalid input data format'}),
                status=400,
                mimetype='application/json'
            )

        # Process the data (resize and transform)
        scaledPosture = process_data(backrest, seat)
        
        if scaledPosture is None:
            return https_fn.Response(
                json.dumps({'error': 'Input data does not form a square matrix'}),
                status=400,
                mimetype='application/json'
            )

        # Load the model and make prediction
        model = load_model('neural_network_32x32.pkl')
               
        # Combine and flatten the matrices for prediction
        combined_features = np.concatenate((scaledPosture["backrest"].flatten(), scaledPosture["seat"].flatten()))
        
        prediction = make_prediction(model, combined_features.tolist())

        # Return the response
        response_data = {'prediction': prediction.tolist()}
        return https_fn.Response(json.dumps(response_data), mimetype='application/json')

    return https_fn.Response('OK', status=200)


@https_fn.on_request(memory=options.MemoryOption.GB_1, cors=options.CorsOptions(cors_origins="*", cors_methods=["get", "post"]))
def hausdorff_distance(req: https_fn.Request) -> https_fn.Response:
    if req.method == "POST":
        try:
            data = req.json
            upright_backrest = np.array(data['upright_backrest'])
            upright_seat = np.array(data['upright_seat'])
            backrest = np.array(data['posture_backrest'])
            seat = np.array(data['posture_seat'])
        except KeyError:
            return https_fn.Response(
                json.dumps({'error': 'Invalid input data format'}),
                status=400,
                mimetype='application/json'
            )

        # Process the data (resize and transform)
        scaledRealPosture = process_data(backrest, seat)
        scaledUprightPosture = process_data(upright_backrest, upright_seat)
       
        # Apply Procrustes analysis
        backrest_mtx1, backrest_mtx2, backrest_disparity = procrustes(upright_backrest, backrest)
        seat_mtx1, seat_mtx2, seat_disparity = procrustes(upright_seat, seat)

        # Calculate Hausdorff distances between pairs
        hausdorff_backrest = calculate_hausdorff(scaledUprightPosture["backrest"], scaledRealPosture["backrest"])
        hausdorff_seat = calculate_hausdorff(scaledUprightPosture["seat"], scaledRealPosture["seat"])
        
        hausdorff_backrest_with_procrustes = calculate_hausdorff(backrest_mtx1, backrest_mtx2)
        hausdorff_seat_with_procrustes = calculate_hausdorff(seat_mtx1, seat_mtx2)
        

        
        weight_hausdorff_backrest = calculate_weighted_hausdorff(scaledUprightPosture["backrest"], scaledRealPosture["backrest"])
        weight_hausdorff_seat = calculate_weighted_hausdorff(scaledUprightPosture["seat"], scaledRealPosture["seat"])
        
        weight_hausdorff_backrest_with_procrustes = calculate_weighted_hausdorff(backrest_mtx1, backrest_mtx2)
        weight_hausdorff_seat_with_procrustes = calculate_weighted_hausdorff(seat_mtx1, seat_mtx2)
        
        # Response data with both Hausdorff distances
        response_data = {
            'hausdorff_backrest': hausdorff_backrest,
            'hausdorff_seat': hausdorff_seat,
            'hausdorff_backrest_with_procrustes': hausdorff_backrest_with_procrustes,
            'hausdorff_seat_with_procrustes': hausdorff_seat_with_procrustes,
            'backrest_procrustes_disparity': backrest_disparity,
            'seat_procrustes_disparity': seat_disparity,
            'weighted_hausdorff_backrest': weight_hausdorff_backrest,
            'weighted_hausdorff_seat': weight_hausdorff_seat,
            'weight_hausdorff_backrest_with_procrustes': weight_hausdorff_backrest_with_procrustes,
            'weight_hausdorff_seat_with_procrustes': weight_hausdorff_seat_with_procrustes
        }

        return https_fn.Response(json.dumps(response_data), mimetype='application/json')

    return https_fn.Response('OK', status=200)
