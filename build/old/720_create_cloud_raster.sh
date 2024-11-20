#!/bin/bash
# -----------------------------------------------------------------
# Create "cloud optimised geotiff" from web raster api. Then load it into the raster table
# in the db.
# Based off of this blog post: https://www.crunchydata.com/blog/postgis-raster-and-crunchy-bridge
#
# Howard County Bounding Box = "POLYGON((-77.187113 39.103142,-77.187113 39.369323,-76.696774 39.369323,-76.696774 39.103142,-77.187113 39.103142))"
# -----------------------------------------------------------------

mkdir -p /tmp/shapes/
mkdir -p /tmp/unzips/
rm -rf /tmp/unzips/*

runscript="${FETCH_GEOM:-False}"
if [ $runscript = "False" ]; then
   echo "--- Skipping all GEOM downloads."
   echo $runscript
   exit 0
fi

# Get WCS info on the Canopy web converage service. 
# # !!!! WCS just doesn't work properly on the webservice. Damnit!

# echo '  -Downloading raster file for NLCD Canopy...' 

# if [ ! -f "/tmp/shapes/cb_2023_24_bg_500k.zip" ]; then
#         echo "--- Downloading CONUS_2019_v2021-4.zip..."
#         wget -q " https://s3-us-west-2.amazonaws.com/mrlc/nlcd_tcc_CONUS_2019_v2021-4.zip" -O "/tmp/shapes/nlcd_tcc_CONUS_2019_v2021-4.zip"
# else 
#         echo "${title} file exists. Skip download."
# fi

# echo " --Unzipping Canopy data..." 
# unzip "/tmp/shapes/nlcd_tcc_CONUS_2019_v2021-4.zip" -d /tmp/unzips/
# ----------------------------------------------------------------- 


# echo '  -Downloading raster file for NLCD Impervious surfaces...' 

# if [ ! -f "/tmp/shapes/cb_2023_24_bg_500k.zip" ]; then
#         echo "--- Downloading cb_nlcd_2019_impervious_l48_20210604.zip..."
#         wget -q "https://s3-us-west-2.amazonaws.com/mrlc/nlcd_2019_impervious_l48_20210604.zip" -O "/tmp/shapes/nlcd_2019_impervious_l48_20210604.zip" 
# else 
#         echo "${title} file exists. Skip download."
# fi

# echo " --Unzipping Impervious Surfaces data..."
# unzip "/tmp/shapes/nlcd_2019_impervious_l48_20210604.zip" -d /tmp/unzips/
# # -----------------------------------------------------------------

# echo " --Loading raster data into DB..."

# gdal_translate -a_nodata 255 -co COMPRESS=DEFLATE -co ZLEVEL=9 -co PREDICTOR=2 -co TILED=YES -ot Byte nlcd_tcc_conus_2019_v2021-4.tif canopy.tif 

# raster2pgsql \
#   -s 5070 \        # SRID of the data
#   -t 256x256 \       # Tile raster
#   # -I \               # Index the table
#   -R \               # Load as "out-db", metadata only
#   /vsicurl/tmp/unzips/nlcd_tcc_CONUS_2019_v2021-4/nlcd_tcc_conus_2019_v2021-4.tif \    # File to reference
#   pop12 \            # Table name to use
#   | psql postgresql://${API_USER}:${API_PW}@deer_database/${DB_NAME}

# raster2pgsql \
#   -s 5070 \        # SRID of the data
#   -t 256x256 \       # Tile raster
#   # -I \               # Index the table
#   -R \               # Load as "out-db", metadata only
#   /vsicurl/tmp/unzips/nlcd_tcc_CONUS_2019_v2021-4/nlcd_tcc_conus_2019_v2021-4.tif \    # File to reference
#   pop12 \            # Table name to use
#   | psql $DATABASE_URL
# # rm -rf /tmp/unzips/*
 
echo '==============================================='
echo 'Downloads Complete and inserted into geo schema' 
echo '==============================================='