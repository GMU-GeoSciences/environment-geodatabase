#!/bin/bash

# Download census block data shapefiles and insert them into the DB
echo "-Downloading and inserting census data..."
mkdir -p /tmp/shapes/
mkdir -p /tmp/shapes/unzips/
rm -rf /tmp/shapes/unzips/*

# and is anything other than "false"
runscript="${FETCH_GEOM:-False}"
if [ $runscript = "False" ]; then
   echo "---Skipping all GEOM downloads."
   echo $runscript
   exit 0
fi

echo "--Fetching 2019 census block data..."
if [ ! -f "/tmp/shapes/cb_2019_24_bg_500k.zip" ]; then
        echo "---Downloading cb_2023_24_bg_500k.zip..."
        wget -q "https://www2.census.gov/geo/tiger/GENZ2019/shp/cb_2019_24_bg_500k.zip" -O "/tmp/shapes/cb_2019_24_bg_500k.zip" 
else 
        echo "---${title} file exists. Skip download."
fi


echo "--Fetching 2023 census block data..."
if [ ! -f "/tmp/shapes/cb_2023_24_bg_500k.zip" ]; then
        echo "---Downloading cb_2023_24_bg_500k.zip..."
        wget -q "https://www2.census.gov/geo/tiger/GENZ2023/shp/cb_2023_24_bg_500k.zip" -O "/tmp/shapes/cb_2023_24_bg_500k.zip" 
else 
        echo "---${title} file exists. Skip download."
fi


echo "--Unzipping census block data..."
unzip "/tmp/shapes/cb_2019_24_bg_500k.zip" -d /tmp/shapes/unzips/
unzip "/tmp/shapes/cb_2023_24_bg_500k.zip" -d /tmp/shapes/unzips/

echo "--Loading census block data into DB..."
shp2pgsql -W Latin1 -s 4269 -I "/tmp/shapes/unzips/cb_2019_24_bg_500k.shp" "geo.maryland_census_blocks_2019" | psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}
shp2pgsql -W Latin1 -s 4269 -I "/tmp/shapes/unzips/cb_2023_24_bg_500k.shp" "geo.maryland_census_blocks_2023" | psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}
rm -rf /tmp/unzips/*

echo '=========================================================='
echo '==Census Downloads Complete and inserted into geo schema==' 
echo '=========================================================='
