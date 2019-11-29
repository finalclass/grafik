#!/bin/bash

docker build \
       --file ./Dockerfile.two-step \
       --build-arg DATABASE_URL=ecto://postgres:$1@localhost/grafik \
       --build-arg SECRET_KEY_BASE=$2 \ 
       --build-arg X_FCSTORE_SECRET=$3 \
       --tag finalclass/grafik:latest \
       .
       
docker push finalclass/grafik:latest

ssh fc1 "fc-grafik sync && fc-grafik restart"

