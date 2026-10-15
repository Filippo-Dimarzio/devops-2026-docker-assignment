#!/bin/sh
# TODO

docker rm -f -v chinook-fdm chinook-gateway

docker network rm chinook-net

docker rmi chinook-seeder:1.0 chinook-agent:1.0

