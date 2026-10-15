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

docker build --target agent -t chinook-agent:1.0 .


docker run -d \
    --name chinook-gateway \
    --network chinook-net \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v "$(pwd)/mcp_config.yaml:/mcp_config.yaml:ro" \
    -v "$(pwd)/mcp_secret.env:/run/secrets/database-url:ro" \
    docker/mcp-gateway:latest \
    --transport=sse \
    --secrets=/run/secrets/database-url \
    --allow-unauthenticated \
    --servers=cockroachdb \
    --tools=execute_query \
    --config=/mcp_config.yaml

    docker run --rm \
    --name chinook-agent \
    --network chinook-net \
    -v "$(pwd)/secret.ollama-api-key:/run/secrets/openai-api-key:ro" \
    -e MCP_SERVER_URL=http://chinook-gateway:8811/sse \
    -e DATABASE_DIALECT=PostgreSQL \
    -e QUESTION="What are the top 3 albums by sales?" \
    -e OPENAI_API_BASE_URL=https://ollama.com/v1 \
    -e OPENAI_MODEL_NAME=gpt-oss:20b \
    chinook-agent:1.0