from flask import Flask
from flask import request
from flask_protobuf import flask_protobuf as FlaskProtobuf

from idl.api_pb2 import OTAUpdateRequest, OTAUpdateResponse, StatusUpdateRequest, StatusUpdateResponse

import statsd


app = Flask(__name__)
fb = FlaskProtobuf(app, parse_dict=True)

@app.route("/")
def default():
    server_stats.incr("default")
    return "Hello, World!"


@app.route("/status_update", methods=['POST'])
@fb(StatusUpdateRequest)
def status_update():
    print(request.data)

    resp = StatusUpdateResponse()
    resp.message = "Boot count: " + str(request.data["bootCount"])
    return resp.SerializeToString()


# IOTEMBSYS9: Add an /ota endpoint that returns the path or URL


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
