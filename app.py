from flask import Flask

app = Flask(__name__)

VERSION = "v2"

@app.route("/")
def home():
    return f"GitOps Demo Application - Version {VERSION}"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)