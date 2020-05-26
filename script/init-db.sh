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

echo "Populating database with items (quiet)..."
# Running this one in quiet mode because it is large, remove pipe to view debug
psql -d ${POSTGRES_DB} -a -U${POSTGRES_USER} -f /data/items.sql > /dev/null

echo "Populating database with users, customers, staff..."
psql -d ${POSTGRES_DB} -a  -U${POSTGRES_USER} -f /data/customers.sql
psql -d ${POSTGRES_DB} -a  -U${POSTGRES_USER} -f /data/staff.sql
psql -d ${POSTGRES_DB} -a -U${POSTGRES_USER} -f /data/users.sql

echo "Populating database with events and event_items, (quiet)..."
psql -d ${POSTGRES_DB} -a  -U${POSTGRES_USER} -f /data/events_event-items.sql

echo "Running post init script (stocks, trigger)..."
psql -d ${POSTGRES_DB} -a  -U${POSTGRES_USER} -f /data/post-init.sql