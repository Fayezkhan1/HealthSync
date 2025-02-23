from flask import Blueprint, request, jsonify

alert_bp = Blueprint('alert', __name__)

@alert_bp.route('/alert', methods=['POST'])
def trigger_alert():
    data = request.get_json()
    title = data.get('title')
    message = data.get('message')

    print(f"🚨 ALERT TRIGGERED 🚨\nTitle: {title}\nMessage: {message}")

    return jsonify({"title": title, "message": message}), 200
