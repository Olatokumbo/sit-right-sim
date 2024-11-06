import numpy as np
from scipy.spatial.distance import directed_hausdorff
from scipy.spatial import distance

def calculate_weighted_hausdorff(upright_array, posture_array):
    """Calculates the weighted Hausdorff distance between two NxN pressure arrays."""
    
    # Ensure both arrays are square matrices of the same shape
    if upright_array.shape != posture_array.shape:
        raise ValueError("Both arrays must be of the same shape.")
    
    n = upright_array.shape[0]  # Get the size of the square matrix (NxN)
    
    # Generate coordinates for the NxN grid for both arrays
    coords = np.array(np.meshgrid(np.arange(n), np.arange(n))).T.reshape(-1, 2)
    
    # Flatten arrays and normalize the values for better weighting
    upright_flat = upright_array.flatten()
    posture_flat = posture_array.flatten()

    # Calculate pairwise Euclidean distances between each point
    distance_matrix = distance.cdist(coords, coords, 'euclidean')
    
    # Compute weighted Hausdorff distances
    weighted_distances = distance_matrix * np.minimum.outer(upright_flat, posture_flat)
    
    # Return the maximum weighted distance
    return np.max(weighted_distances)


def calculate_hausdorff(array1, array2):
    """Calculates the Hausdorff distance between two feature arrays."""
    
    hausdorff_dist, _, _ = directed_hausdorff(array1, array2)
    return hausdorff_dist