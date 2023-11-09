# UW IOT Embsys Assignments
Backend assignments for the UW Embedded Systems IoT Specialization

## Details
This repository contains the source for standing up the backend infrastructure as well as the services and applications that run on said infrastructure. To keep things simple, all infrastructure will be defined in `main.tf`, and any of its dependencies are in the `config/` directory.

Throughout the course, there will be 3 separate servers that you work on: the `tcp_server.py` for implementing TCP and sockets, `http_server.py` for implementing HTTP, and lastly the main application server, which is in the `server/` directory.
