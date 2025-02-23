from flask import Flask
from login import login_bp
from flask_cors import CORS
from blink_rate import blink_bp
from cataract import cataract_bp
from lungs import lungs_bp
from acne import acne_bp
import os
from report import report_bp
from alert import alert_bp 

app = Flask(__name__)
CORS(app)

app.register_blueprint(login_bp)
app.register_blueprint(blink_bp)
app.register_blueprint(cataract_bp)
app.register_blueprint(lungs_bp)
app.register_blueprint(acne_bp)
app.register_blueprint(report_bp)
app.register_blueprint(alert_bp)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
