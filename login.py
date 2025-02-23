import config 
import os
from flask import Blueprint, request

login_bp = Blueprint('login', __name__)
def clear_folder(folder_path):
    for filename in os.listdir(folder_path):
        file_path = os.path.join(folder_path, filename)
        if os.path.isfile(file_path):
            os.remove(file_path)

@login_bp.route('/login', methods=['POST'])
def submit_data():
    data = request.get_json()
    config.Name= data.get('name')
    config.Phone =data.get('phone_number')
    clear_folder('Storage/Input/Acne')
    clear_folder('Storage/Input/Blink')
    clear_folder('Storage/Input/Cataract')
    clear_folder('Storage/Input/Skin')
    clear_folder('Storage/Input/Lungs')
    clear_folder('Storage/Output/Acne')
    clear_folder('Storage/Output/Blink')
    clear_folder('Storage/Output/Cataract')
    clear_folder('Storage/Output/Skin')
    return '', 200

if __name__ == '__main__':
    print('Hello World')