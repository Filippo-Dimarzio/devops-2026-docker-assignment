#!/bin/sh

set -e

docker build -t assignment-demo:1.0 ./sample-app/

docker run -d --name assignment \
    -p 3000:80 \
    --name chinook-fdm \
    --network chinook-net \
    -e POSTGRES_USER=chinook-fdm \
    -e POSTGRES_PASSWORD=assignment1 \
    -e POSTGRES_DB=chinook-fdm-database \
    postgresconfigu

sleep 10
echo "Container started"

