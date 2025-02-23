# from flask import Blueprint, request, jsonify
# from ultralytics import YOLO
# import cv2
# import os
# import io
# import base64
# from PIL import Image
# import config
# from config import get_medical_comment, get_comment

# acne_bp = Blueprint('acne', __name__)

# @acne_bp.route('/acne', methods=['POST'])
# def detect_acne():
#     file1 = request.files['acne1']
#     file2 = request.files['acne2']

#     input_dir = os.path.join(os.getcwd(), "Storage", "Input", "Acne")
#     output_dir = os.path.join(os.getcwd(), "Storage", "Output", "Acne")
#     os.makedirs(input_dir, exist_ok=True)
#     os.makedirs(output_dir, exist_ok=True)

#     model = YOLO("Models/Acne Detector.pt")

#     input_path1 = os.path.join(input_dir, file1.filename)
#     input_path2 = os.path.join(input_dir, file2.filename)

#     file1.save(input_path1)
#     file2.save(input_path2)

#     result1 = process_image(model, input_path1, output_dir, "acne1")
#     result2 = process_image(model, input_path2, output_dir, "acne2")
    
#     # config.Diagnoses["skin1"] = {
#     #     "diagnosis_result": ", ".join(result1["label"]),
#     #     "image": result1["image"],
#     #     "comment": get_medical_comment('Skin', result1["label"])
#     # }

#     # config.Diagnoses["skin2"] = {
#     #     "diagnosis_result": ", ".join(result2["label"]),
#     #     "image": result2["image"],
#     #     "comment": get_medical_comment('Skin', result2["label"])
#     # }

#     # print("Skin1 Comment:", config.Diagnoses["skin1"]["comment"])
#     # print("Skin2 Comment:", config.Diagnoses["skin2"]["comment"])



#     return jsonify({
#         "acne1": result1,
#         "acne2": result2
#     }), 200

# def process_image(model, input_path, output_dir, output_name):
#     image = cv2.imread(input_path)
#     results = model(image)

#     unique_labels = set()
#     for r in results:
#         for box in r.boxes:
#             class_id = int(box.cls[0])
#             class_name = r.names[class_id]
#             unique_labels.add(class_name)

#         annotated_frame = r.plot()
#         output_path = os.path.join(output_dir, f"{output_name}.jpg")
#         cv2.imwrite(output_path, annotated_frame)

#     img_base64 = image_to_base64(output_path)

    

#     return {
#         "label": list(unique_labels),
#         "image": img_base64
#     }

# def image_to_base64(image_path):
#     with Image.open(image_path) as img:
#         img_io = io.BytesIO()
#         img.save(img_io, format='PNG')
#         img_io.seek(0)
#         img_base64 = base64.b64encode(img_io.getvalue()).decode('utf-8')
#     return img_base64

from flask import Blueprint, request, jsonify
from ultralytics import YOLO
import cv2
import os
import io
import base64
from PIL import Image
import config
from config import get_medical_comment, get_comment

acne_bp = Blueprint('acne', __name__)

# Mapping for labels
LABEL_MAPPING = {
    "white": "Whitehead",
    "black": "Blackhead"
}

@acne_bp.route('/acne', methods=['POST'])
def detect_acne():
    file1 = request.files['acne1']
    file2 = request.files['acne2']

    input_dir = os.path.join(os.getcwd(), "Storage", "Input", "Acne")
    output_dir = os.path.join(os.getcwd(), "Storage", "Output", "Acne")
    os.makedirs(input_dir, exist_ok=True)
    os.makedirs(output_dir, exist_ok=True)

    model = YOLO("Models/Acne Detector.pt")

    input_path1 = os.path.join(input_dir, file1.filename)
    input_path2 = os.path.join(input_dir, file2.filename)

    file1.save(input_path1)
    file2.save(input_path2)

    result1 = process_image(model, input_path1, output_dir, "acne1")
    result2 = process_image(model, input_path2, output_dir, "acne2")

    config.Diagnoses["skin1"] = {
        "diagnosis_result": ", ".join(result1["label"]),
        "image": result1["image"],
        "comment": get_medical_comment('Skin', ", ".join(result1["label"]))
    }

    config.Diagnoses["skin2"] = {
        "diagnosis_result": ", ".join(result2["label"]),
        "image": result2["image"],
        "comment": get_medical_comment('Skin', ", ".join(result2["label"]))
    }


    return jsonify({
        "acne1": result1,
        "acne2": result2
    }), 200

def process_image(model, input_path, output_dir, output_name):
    image = cv2.imread(input_path)
    results = model(image)

    unique_labels = set()
    for r in results:
        for box in r.boxes:
            class_id = int(box.cls[0])
            class_name = r.names[class_id]
            mapped_label = LABEL_MAPPING.get(class_name, class_name)
            unique_labels.add(mapped_label)

        annotated_frame = r.plot()
        output_path = os.path.join(output_dir, f"{output_name}.jpg")
        cv2.imwrite(output_path, annotated_frame)

    img_base64 = image_to_base64(output_path)

    return {
        "label": list(unique_labels),
        "image": img_base64
    }

def image_to_base64(image_path):
    with Image.open(image_path) as img:
        img_io = io.BytesIO()
        img.save(img_io, format='PNG')
        img_io.seek(0)
        img_base64 = base64.b64encode(img_io.getvalue()).decode('utf-8')
    return img_base64
