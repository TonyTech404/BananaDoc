import numpy as np
from PIL import Image
import tensorflow as tf
from tensorflow.keras.preprocessing import image
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input

def load_and_preprocess_image(img_path, target_size=(224, 224)):
    """
    Load and preprocess an image from a file path
    
    Args:
        img_path: Path to the image file
        target_size: Size to resize the image to (default: 224x224)
        
    Returns:
        Preprocessed image array ready for model prediction
    """
    img = image.load_img(img_path, target_size=target_size)
    return preprocess_pil_image(img)

def preprocess_pil_image(pil_img, target_size=(224, 224)):
    """
    Preprocess a PIL Image object
    
    Args:
        pil_img: PIL Image object
        target_size: Size to resize the image to (default: 224x224)
        
    Returns:
        Preprocessed image array ready for model prediction
    """
    if pil_img.mode != 'RGB':
        pil_img = pil_img.convert('RGB')
    
    pil_img = pil_img.resize(target_size)
    img_array = image.img_to_array(pil_img)
    img_array = np.expand_dims(img_array, axis=0)
    img_array = preprocess_input(img_array)
    return img_array

def load_image_from_bytes(image_bytes, target_size=(224, 224)):
    """
    Load an image from bytes (e.g., from a file upload)
    
    Args:
        image_bytes: Image as bytes
        target_size: Size to resize the image to (default: 224x224)
        
    Returns:
        Preprocessed image array ready for model prediction
    """
    img = Image.open(image_bytes)
    return preprocess_pil_image(img, target_size)

def decode_and_load_base64_image(base64_string, target_size=(224, 224)):
    """
    Decode a base64 string and load it as an image
    
    Args:
        base64_string: Base64 encoded image string
        target_size: Size to resize the image to (default: 224x224)
        
    Returns:
        Preprocessed image array ready for model prediction
    """
    import base64
    from io import BytesIO
    
    image_bytes = base64.b64decode(base64_string)
    return load_image_from_bytes(BytesIO(image_bytes), target_size) 