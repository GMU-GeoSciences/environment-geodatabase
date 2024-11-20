-- Create schemas to hold all the tables.

CREATE SCHEMA gps; -- holds gps data
CREATE SCHEMA postgisftw; -- Holds API views

CREATE SCHEMA pop; -- Hold population information
CREATE SCHEMA geo; -- Hold helper geometry information that is not generated from data
CREATE schema osm; -- Hold OpenStreetMap data

CREATE EXTENSION IF NOT EXISTS postgis;

-- https://www.crunchydata.com/blog/postgis-raster-and-crunchy-bridge
CREATE EXTENSION IF NOT EXISTS postgis_raster;
ALTER DATABASE postgres SET postgis.enable_outdb_rasters = true;
ALTER DATABASE postgres SET postgis.gdal_enabled_drivers TO 'ENABLE_ALL';

CREATE EXTENSION IF NOT EXISTS hstore;
CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;
CREATE EXTENSION IF NOT EXISTS timescaledb with SCHEMA gps;

