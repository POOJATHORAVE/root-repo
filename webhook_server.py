from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/github-webhook/', methods=['POST'])
def github_webhook():
    data = request.json
    print("Received webhook payload:")
    print(data)  # Logs the JSON payload from GitHub
    return jsonify({"status": "ok"}), 200  # GitHub expects HTTP 200

if __name__ == "__main__":
    # Make sure the port matches your ngrok tunnel
    app.run(host='0.0.0.0', port=5000)
