#!/bin/bash
set -e

POSTGRES="psql --username ${POSTGRES_USER}"

echo "Creating database: ${POSTGRES_DB}"

$POSTGRES <<EOSQL
CREATE DATABASE ${DB_NAME} OWNER ${POSTGRES_USER};
EOSQL

echo "Creating schema..."
psql -d ${POSTGRES_DB} -a -U${POSTGRES_USER} -f /data/shop-schema.sql

echo "Populating database..."
psql -d ${POSTGRES_DB} -a  -U${POSTGRES_USER} -f /data/products.sql