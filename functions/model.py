from tensorflow.keras.models import load_model
import numpy as np

def load_trained_model(model_path):
    """Load the pre-trained machine learning model."""
    model = load_model(model_path)  # Corrected loading method
    print('Model loaded successfully.')
    return model

def make_prediction(model, features):
    reshaped_features = np.array(features).reshape(1, 32, 32, 2)
    prediction = model.predict(reshaped_features)
    return prediction