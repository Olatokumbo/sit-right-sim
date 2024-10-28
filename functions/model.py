import joblib

def load_model(model_path):
    """Load the pre-trained machine learning model."""
    model = joblib.load(model_path)
    print('Model loaded')
    return model

def make_prediction(model, processed_features):
    """Make a prediction based on the processed features."""
    prediction = model.predict([processed_features])
    print('Prediction:', prediction)
    return prediction