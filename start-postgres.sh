#!/bin/bash

set -euo pipefail
echo "[INFO] stoping pg-docker if it already exists"
docker stop pg-docker || true

docker run --rm --name pg-docker -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=dev -d -p 5432:5432 -v $PWD/volume/postgres:/var/lib/postgresql/shared-volume postgres
sleep 1
echo "[INFO] initiating schema"
docker exec pg-docker psql -U postgres -d dev -f /var/lib/postgresql/shared-volume/shop-schema.sql
echo "[INFO] inserting products"
docker exec pg-docker psql -U postgres -d dev -f /var/lib/postgresql/shared-volume/products.sql
echo "Done."
# docker stop $(docker ps -aq)