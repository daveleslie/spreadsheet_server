#!/bin/bash
sudo docker build . -t spreadsheet_server
sudo docker stop spreadsheet_server
sudo docker rm spreadsheet_server
sudo docker run -d \
  -v ./spreadsheets/:/home/libreuser/spreadsheet_server/spreadsheets \
  -v ./saved_spreadsheets/:/home/libreuser/spreadsheet_server/saved_spreadsheets \
  -v ./log/:/home/libreuser/spreadsheet_server/log \
  --restart always \
  -p 5555:5555 \
  --name spreadsheet_server spreadsheet_server
