#!/bin/bash

source .secret.sh

cd app

docker build \
       --file ./Dockerfile \
       --build-arg DATABASE_URL=ecto://postgres:$DB_PASSWORD@localhost/grafik \
       --build-arg SECRET_KEY_BASE=$SECRET_KEY_BASE \
       --build-arg X_FCSTORE_SECRET=$X_FCSTORE_SECRET \
       --tag finalclass/grafik:latest \
       .
       
docker push finalclass/grafik:latest

ssh fc1 "fc-grafik sync && fc-grafik restart"

