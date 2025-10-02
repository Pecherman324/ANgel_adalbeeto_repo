from flask import Flask, render_template, jsonify
import os
from datetime import datetime

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/status')
def status():
    return jsonify({
        'status': 'OK',
        'timestamp': datetime.now().isoformat(),
        'environment': os.getenv('ENVIRONMENT', 'development')
    })

@app.route('/api/health')
def health():
    return jsonify({
        'health': 'healthy',
        'version': '1.0.0',
        'uptime': 'running'
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
