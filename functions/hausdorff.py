import numpy as np
from scipy.spatial.distance import directed_hausdorff

def calculate_weighted_hausdorff(upright_array, posture_array):
    """Calculates the weighted Hausdorff distance between two NxN pressure arrays."""
    
    # Ensure both arrays are square matrices of the same shape
    if upright_array.shape != posture_array.shape:
        raise ValueError("Both arrays must be of the same shape.")
    
    n = upright_array.shape[0]  # Get the size of the square matrix (NxN)
    
    # Generate coordinates for the NxN grid
    upright_coords = np.array(np.meshgrid(np.arange(n), np.arange(n))).T.reshape(-1, 2)
    
    # Flatten the arrays to 1D for processing
    upright_flat = upright_array.flatten()
    posture_flat = posture_array.flatten()
    
    # Initialize weighted distances
    weighted_distances = []

    # Calculate weighted Hausdorff distances
    for i in range(len(upright_flat)):
        for j in range(len(posture_flat)):
            distance = np.linalg.norm(upright_coords[i] - upright_coords[j])  # Euclidean distance
            weight = min(upright_flat[i], posture_flat[j])  # Use the smaller pressure value for weighting
            
            # Append the weighted distance
            weighted_distance = distance * weight
            weighted_distances.append(weighted_distance)
            
            # Debug: Print each distance and weight
            print(f"i: {i}, j: {j}, distance: {distance}, weight: {weight}, weighted_distance: {weighted_distance}")

    # The weighted Hausdorff distance is the maximum of the weighted distances
    return max(weighted_distances)





def calculate_hausdorff(array1, array2):
    """Calculates the Hausdorff distance between two feature arrays."""
    
    # Assuming your arrays are flattened and each pair of values is [x, y]
    array1_reshaped = array1.reshape(-1, 2)  # Reshape to have 2 columns
    array2_reshaped = array2.reshape(-1, 2)  # Reshape to have 2 columns
    
    # Calculate the Hausdorff distance
    hausdorff_dist, _, _ = directed_hausdorff(array1_reshaped, array2_reshaped)
    return hausdorff_dist