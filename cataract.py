import os
import io
import base64
from PIL import Image
from ultralytics import YOLO
from flask import Blueprint, request, jsonify
import config
from config import get_medical_comment, get_comment

cataract_bp = Blueprint('cataract', __name__)

INPUT_FOLDER = os.path.join(os.getcwd(), 'Storage', 'Input', 'Cataract')
OUTPUT_FOLDER = os.path.join(os.getcwd(), 'Storage', 'Output', 'Cataract')

os.makedirs(INPUT_FOLDER, exist_ok=True)
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

@cataract_bp.route('/cataract', methods=['POST'])
def cataract_diagnosis():


    left_eye = request.files['left_eye']
    right_eye = request.files['right_eye']

    left_image_path = os.path.join(INPUT_FOLDER, left_eye.filename)
    right_image_path = os.path.join(INPUT_FOLDER, right_eye.filename)

    left_eye.save(left_image_path)
    right_eye.save(right_image_path)

    left_label = classify_eye(left_image_path, 'left_eye')
    right_label = classify_eye(right_image_path, 'right_eye')

    left_eye_path, left_eye_caption = apply_segmentation(
        left_image_path,
        r"Models\Healthy Eye Segmenter.pt" if left_label.lower() == 'normal' else r"Models\Cataract Eye Segmenter.pt",
        left_eye.filename, left_label
    )

    right_eye_path, right_eye_caption = apply_segmentation(
        right_image_path,
        r"Models\Healthy Eye Segmenter.pt" if right_label.lower() == 'normal' else r"Models\Cataract Eye Segmenter.pt",
        right_eye.filename, right_label
    )

    left_img = Image.open(left_eye_path)
    right_img = Image.open(right_eye_path)

    left_img_b64 = image_to_base64(left_img)
    right_img_b64 = image_to_base64(right_img)


    left_eye_comment = get_medical_comment('Left Eye', left_label) if left_label.lower() != 'normal' else get_comment('Left Eye')
    right_eye_comment = get_medical_comment('Right Eye', right_label) if right_label.lower() != 'normal' else get_comment('Right Eye')

    # Update Diagnoses in Config
    config.Diagnoses['left_eye'] = {
        "diagnosis_result": left_label,
        "image": left_img_b64,
        "comment": left_eye_comment
    }

    config.Diagnoses['right_eye'] = {
        "diagnosis_result": right_label,
        "image": right_img_b64,
        "comment": right_eye_comment
    }

    return jsonify({
        'left_eye': {
            'image': left_img_b64,
            'caption': left_eye_caption
        },
        'right_eye': {
            'image': right_img_b64,
            'caption': right_eye_caption
        }
    }), 200

def image_to_base64(image):
    img_io = io.BytesIO()
    image.save(img_io, format='PNG')  
    img_io.seek(0)
    img_base64 = base64.b64encode(img_io.getvalue()).decode('utf-8')
    return img_base64

def classify_eye(image_path, eye_label):
    model = YOLO(r"Models\Eye Classifier.pt")
    results = model(image_path, verbose=True)
    class_names = results[0].names
    probs = results[0].probs.data.tolist()
    max_confidence_index = probs.index(max(probs))
    label = class_names[max_confidence_index]
    return label

def apply_segmentation(image_path, model_path, filename, result):
    segmenter_model = YOLO(model_path)
    results = segmenter_model(image_path, verbose=True)
    output_image = results[0].plot()

    output_image_path = os.path.join(OUTPUT_FOLDER, filename)
    Image.fromarray(output_image).save(output_image_path)

    if result.lower() == "normal":
        caption = "The eye appears healthy. No signs of cataract detected."
    elif result.lower() == "cataract":
        caption = "Cataract detected. It is advised to consult an eye specialist for further evaluation."
    else:
        caption = "No clear diagnosis could be made. Please consult a medical expert."

    return output_image_path, caption
