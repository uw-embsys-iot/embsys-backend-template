from flask import Flask
from flask import request
from flask_protobuf import flask_protobuf as FlaskProtobuf

from idl.api_pb2 import StatusUpdateRequest, StatusUpdateResponse

app = Flask(__name__)
fb = FlaskProtobuf(app, parse_dict=True)

@app.route("/")
def default():
    return "Hello, World!"


@app.route("/status_update", methods=['POST'])
@fb(StatusUpdateRequest)
def status_update():
    print(request.data)

    resp = StatusUpdateResponse()
    resp.message = "Boot count: " + str(request.data["bootCount"])
    return resp.SerializeToString()


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
