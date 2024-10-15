# Dockerfile for production instance
FROM timescale/timescaledb-ha:pg16.1-ts2.13.1
USER root
RUN  apt-get update \
  && apt-get install -y wget postgis unzip osm2pgsql osm2pgrouting\
  && rm -rf /var/lib/apt/lists/*
USER postgres
# Select which scripts to run on first DB startup:
COPY ./build/db_init_scripts /docker-entrypoint-initdb.d/
# COPY ./build/db_init_scripts_prod /docker-entrypoint-initdb.d/
COPY ./build/db_init_data /tmp/db_init_data/
RUN mkdir /tmp/unzips 
RUN mkdir /tmp/shapes 

# # Postgres ML installation:
# # https://github.com/postgresml/postgresml/blob/master/docker/Dockerfile
# USER root
# RUN echo "deb [trusted=yes] https://apt.postgresml.org jammy main" | \
#     tee -a /etc/apt/sources.list
# RUN apt update && \
# 	apt install -y \
# 	postgresml-16 
 
# USER postgres
