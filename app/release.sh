#!/bin/bash

# export DATABASE_URL=ecto://postgres:awefiwr222@localhost/grafik
export DATABASE_URL=ecto://postgres:e3i29rse20-r!@localhost/grafik
export MIX_ENV=prod
export SECRET_KEY_BASE=arse3erirsefruienrst82nert8ttrmarstienrfrmrfpierf22189rerst8rtein38yrstienr3y8nritsxenri3p8unristemxc.t,mory38pnriftsrt

cd assets
npm run deploy
cd ../

mix compile
mix release

docker build -t finalclass/grafik:latest .

# docker build --build-arg SECRET_KEY_BASE=$1 --build-arg DATABASE_URL=ecto://postgres:$2@localhost/postgres -t finalclass/grafik:latest .

# docker push finalclass/grafik:latest

# ssh fc1 "fc-grafik sync && fc-grafik restart"
