from flask import Blueprint, request, jsonify, send_file
import cv2
from datetime import datetime
import base64
from cvzone.FaceMeshModule import FaceMeshDetector
import os
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from moviepy import VideoFileClip
import config
from config import get_medical_comment, get_comment

blink_bp = Blueprint('blink', __name__)

detector = FaceMeshDetector(maxFaces=1)

INPUT_FOLDER = "Storage/Input/Blink"
OUTPUT_FOLDER = "Storage/Output/Blink"

os.makedirs(INPUT_FOLDER, exist_ok=True)
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

@blink_bp.route('/blink_rate', methods=['POST'])
def process_video():
    video_file = request.files['video']
    video_path = os.path.join(INPUT_FOLDER, video_file.filename)
    video_file.save(video_path)
    blink_rate, graph_image = process_blink_detection(video_path)

    if blink_rate < 10 or blink_rate > 20:
        comment = get_medical_comment("Blink Rate", f"{int(blink_rate)} blinks/min")
    else:
        comment = get_comment("Blink Rate")

    config.Diagnoses['blink_rate'] = {
        "diagnosis_result": "Low" if blink_rate < 10 else "High" if blink_rate > 20 else "Normal",
        "blink_rate": int(blink_rate),
        "graph_image": graph_image,
        "comment": comment
    }


    response = {
        "blink_rate": blink_rate,
        "caption": generate_caption(blink_rate),
        "graph_image": graph_image
    }
    return jsonify(response)

def process_blink_detection(video_path):
    cap = cv2.VideoCapture(video_path)
    blinkCounter = 0
    blink_ratios = []

    output_video_path = os.path.join(OUTPUT_FOLDER, "annotated_" + os.path.basename(video_path))
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    fps = int(cap.get(cv2.CAP_PROP_FPS))
    out = cv2.VideoWriter(output_video_path, fourcc, fps, (height, width))

    clip = VideoFileClip(video_path)
    duration_sec = clip.duration

    blinkThreshhold = 35
    blinkCooldown = 10
    cooldownCounter = 0

    while True:
        success, img = cap.read()
        if not success:
            break

        img = cv2.rotate(img, cv2.ROTATE_90_CLOCKWISE)
        img, faces = detector.findFaceMesh(img, draw=False)

        if faces:
            face = faces[0]
            leftUp = face[159]
            leftDown = face[23]
            leftLeft = face[130]
            leftRight = face[243]
            lenghtVer, _ = detector.findDistance(leftUp, leftDown)
            lenghtHor, _ = detector.findDistance(leftLeft, leftRight)
            ratio = int((lenghtVer / lenghtHor) * 100)
            blink_ratios.append(ratio)

            if cooldownCounter == 0 and ratio < blinkThreshhold:
                blinkCounter += 1
                cooldownCounter = blinkCooldown
                print(f"Blink #{blinkCounter} at {datetime.now()}")
                cv2.putText(img, f"Blink Count: {blinkCounter}", (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)

            if cooldownCounter > 0:
                cooldownCounter -= 1

        out.write(img)

    cap.release()
    out.release()
    clip.close()
    blink_rate = (blinkCounter / duration_sec) * 60

    graph_path = os.path.join(OUTPUT_FOLDER, "blink_graph.png")
    plt.figure(figsize=(10, 4))
    plt.plot(blink_ratios, color='blue')
    plt.title("Blink Ratio Over Time")
    plt.xlabel("Frames")
    plt.ylabel("Blink Ratio")
    plt.savefig(graph_path)
    plt.close()

    with open(graph_path, "rb") as image_file:
        graph_base64 = base64.b64encode(image_file.read()).decode('utf-8')

    return blink_rate, graph_base64

def generate_caption(blink_rate):
    if blink_rate < 10:
        return f"Your blink rate is {int(blink_rate)} blinks/min — Considered low."
    elif 10 <= blink_rate <= 20:
        return f"Your blink rate is {int(blink_rate)} blinks/min — Normal blink rate."
    else:
        return f"Your blink rate is {int(blink_rate)} blinks/min — Higher than average."

if __name__ == "__main__":
    video_path = r"Storage/Input/Blink/sample_video.mp4"
    process_blink_detection(video_path)
