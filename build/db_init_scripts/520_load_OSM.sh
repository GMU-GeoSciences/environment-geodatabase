#!/bin/bash

# Download census block data shapefiles and insert them into the DB
echo "-Downloading and inserting OSM data..."
mkdir -p /tmp/shapes/
mkdir -p /tmp/shapes/unzips/
rm -rf /tmp/shapes/unzips/*

# and is anything other than "false"
runscript="${FETCH_GEOM:-False}"
if [ $runscript = "False" ]; then
   echo "--Skipping all OSM downloads."
   echo $runscript
   exit 0
fi

echo "--Fetching OSM data..."
if [ ! -f "/tmp/shapes/maryland-latest.osm.pbf" ]; then
        echo "---Downloading maryland-latest.osm.pbf..."
        wget -q "https://download.geofabrik.de/north-america/us/maryland-latest.osm.pbf" -O "/tmp/shapes/maryland-latest.osm.pbf" 
else 
        echo "---OSM file exists. Skip download."
fi

echo "--Inserting OSM data into DB..."
# osm2pgsql --version 
# This doesn't work while the DB is still loading. Not sure why... must be todo with the DB no accepting connections yet. 
# Also ubuntu only has access to ver 1.6 of osm2pgsql, which doesn't allow custom schemas, everything goes into public...
osm2pgsql -c -s /tmp/shapes/maryland-latest.osm.pbf -U ${POSTGRES_USER} -d ${POSTGRES_DB}

osm2pgrouting \
  --username ${POSTGRES_USER} \
  --password postgres \
  --host 127.0.0.1 \
  --dbname routing \
  --file /tmp/shapes/maryland-latest.osm.pbf
  
# postgresql://gmu:super_secret_password@localhost/deer  
echo '======================================================='
echo '==OSM Downloads Complete and inserted into OSM schema=='
echo '======================================================='
