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


docker build --target seeder -t chinook-seeder:1.0 .

until docker exec chinook-fdm pg_isready -U chinook-fdm1; do sleep 1; done

docker run --rm \
    --name chinook-seeder \
    --network chinook-net \
    -v "$(pwd)/Chinook.db:/app/Chinook.db:ro" \
    -e SQLITE_FILE=/app/Chinook.db \
    -e DATABASE_URL=postgres://chinook-fdm1:assignment1@chinook-fdm:5432/chinook-fdm-database \
    chinook-seeder:1.0
    