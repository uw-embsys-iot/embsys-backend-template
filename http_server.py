from flask import Flask
from flask import request

app = Flask(__name__)

@app.route("/")
def default():
    return "Hello, World!"


# IOTEMBSYS: Implement the GET and POST handlers (either as separate routes or a single one)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
