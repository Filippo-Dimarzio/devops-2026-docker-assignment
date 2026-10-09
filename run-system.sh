#!/bin/sh

set -e

docker network create chinook-net

docker run -d \
    --name chinook-fdm \
    --network chinook-net \
    -e POSTGRES_USER=chinook-fdm1 \
    -e POSTGRES_PASSWORD=assignment1 \
    -e POSTGRES_DB=chinook-fdm-database \
    postgres


