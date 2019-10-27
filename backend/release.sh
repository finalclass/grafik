#!/bin/bash

# SECRET_KEY_BASE="$1" DATABASE_URL="ecto://postgres:$2@localhost/postgres" MIX_ENV=prod mix release
# docker build --no-cache -t grafik:latest .

docker build --build-arg SECRET_KEY_BASE=$1 --build-arg DATABASE_URL=ecto://postgres:$2@localhost/postgres -t finalclass/grafik:latest .

docker push finalclass/grafik:latest

ssh fc1 "fc-grafik sync && fc-grafik restart"
