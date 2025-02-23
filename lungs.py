from flask import Blueprint, request
import os
import joblib
import librosa
import numpy as np
import config
from config import get_medical_comment, get_comment


lungs_bp = Blueprint('lungs', __name__)

INPUT_FOLDER = os.path.join('Storage', 'Input', 'Lungs')
os.makedirs(INPUT_FOLDER, exist_ok=True)



@lungs_bp.route('/lungs', methods=['POST'])
def diagnose_audio():
    file = request.files.get('audio_file')
    if not file or file.filename == '':
        return '', 400

    file_path = os.path.join(INPUT_FOLDER, file.filename)
    file.save(file_path)

    model = joblib.load(r'Models\Lung Sound Classifier.pkl')

    class_labels = {
        0: "Normal",
        1: "Crackles",
        2: "Wheezes",
        3: "Both Crackles & Wheezes"
    }

    y, sr = librosa.load(file_path, sr=22050)
    mfcc = librosa.feature.mfcc(y=y, sr=sr, n_mfcc=40)
    mfcc_mean = np.mean(mfcc.T, axis=0).reshape(1, -1)

    prediction = model.predict(mfcc_mean)[0]
    result = class_labels[prediction]

    if result == "Normal":
        comment = get_comment("Lungs")
    else:
        comment = get_medical_comment("Lungs", result)

    config.Diagnoses['lungs'] = {
        "diagnosis_result": result,
        "comment": comment
    }
    print(config.Diagnoses['lungs'])

    return result, 200
