#!/bin/bash
# -----------------------------------------------------------------
# Create "cloud optimised geotiff" from web raster api. Then load it into the raster table
# in the db.
# Based off of this blog post: https://www.crunchydata.com/blog/postgis-raster-and-crunchy-bridge
#
# Howard County Bounding Box = "POLYGON((-77.187113 39.103142,-77.187113 39.369323,-76.696774 39.369323,-76.696774 39.103142,-77.187113 39.103142))"
# -----------------------------------------------------------------
echo "-Downloading and inserting NLCD Raster data..."
mkdir -p /tmp/shapes/
mkdir -p /tmp/unzips/
rm -rf /tmp/unzips/*
cp /tmp/db_init_data/*.tiff /tmp/shapes/.
ls /tmp/shapes/

# and is anything other than "false"
runscript="${FETCH_GEOM:-False}"
if [ $runscript = "False" ]; then
   echo "---Skipping all NLCD downloads."
   echo $runscript
   exit 0
fi

echo "--Fetching landcover2019 data..."
if [ ! -f "/tmp/shapes/landcover2019.tiff" ]; then
        echo "---Downloading landcover2019.tiff..."
        wget -O /tmp/shapes/landcover2019.tiff "https://www.mrlc.gov/geoserver/ows?service=WCS&version=2.0.1&&REQUEST=GetCoverage&coverageId=mrlc_download:NLCD_2019_Land_Cover_L48&SUBSETTINGCRS=EPSG:4326&subset=Long(-77.187113,-76.696774)&subset=Lat(39.103142,39.369323)&FORMAT=image/tiff"
else 
        echo "---landcover2019 exists. Skip download."
fi

echo '--Downloading 2019 Canopy Raster...'
if [ ! -f "/tmp/shapes/canopy2019.tiff" ]; then
        echo "---Downloading canopy2019.tiff..."
        wget -O /tmp/shapes/canopy2019.tiff "https://www.mrlc.gov/geoserver/ows?service=WCS&version=2.0.1&&REQUEST=GetCoverage&coverageId=mrlc_download:nlcd_tcc_conus_2019_v2021-4&SUBSETTINGCRS=EPSG:4326&subset=Long(-77.187113,-76.696774)&subset=Lat(39.103142,39.369323)&FORMAT=image/tiff"
else 
        echo "---canopy2019 exists. Skip download."
fi


echo '--Downloading 2019 Impervious Surfaces Raster...'
if [ ! -f "/tmp/shapes/imperv2019.tiff" ]; then
        echo "---Downloading imperv2019.tiff..."
        wget -O /tmp/shapes/imperv2019.tiff "https://www.mrlc.gov/geoserver/ows?service=WCS&version=2.0.1&&REQUEST=GetCoverage&coverageId=mrlc_download:NLCD_2019_Impervious_L48&SUBSETTINGCRS=EPSG:4326&subset=Long(-77.187113,-76.696774)&subset=Lat(39.103142,39.369323)&FORMAT=image/tiff"
else 
        echo "---imperv2019 exists. Skip download."
fi

ls /tmp/shapes/ -lah
cd /tmp/shapes/
raster2pgsql  -I -s 4326 -t 32x32 /tmp/shapes/landcover2019.tiff  geo.landcover | psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}
raster2pgsql  -I -s 4326 -t 32x32 /tmp/shapes/canopy2019.tiff  geo.canopy | psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}
raster2pgsql  -I -s 4326 -t 32x32 /tmp/shapes/imperv2019.tiff  geo.surface | psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}
 
echo '=========================================================='
echo '==Raster downloads Complete and inserted into geo schema=='
echo '=========================================================='