FROM debezium/postgres
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres
ENV POSTGRES_DB=dev
COPY volume/postgres/* /data/
COPY script/* /docker-entrypoint-initdb.d/