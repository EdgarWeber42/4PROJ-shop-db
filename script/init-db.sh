#!/bin/bash
set -e

POSTGRES="psql --username ${POSTGRES_USER}"

echo "Creating database: ${POSTGRES_DB}"

$POSTGRES <<EOSQL
CREATE DATABASE ${POSTGRES_DB} OWNER ${POSTGRES_USER};
EOSQL

echo "Creating schema..."
psql -d ${POSTGRES_DB} -a -U${POSTGRES_USER} -f /data/shop-schema.sql

echo "Populating database with products, stores, devices..."
psql -d ${POSTGRES_DB} -a  -U${POSTGRES_USER} -f /data/data.sql

echo "Populating database with items..."
# Running this one in quiet mode because it is large, remove pipe to view debug
psql -d ${POSTGRES_DB} -a -U${POSTGRES_USER} -f /data/items.sql > /dev/null

echo "Running post init script (stocks, trigger)..."
psql -d ${POSTGRES_DB} -a  -U${POSTGRES_USER} -f /data/post-init.sql