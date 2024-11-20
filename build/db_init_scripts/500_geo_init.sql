CREATE SCHEMA IF NOT EXISTS geo;
CREATE EXTENSION IF NOT EXISTS postgis;
-----------------------------------------------------------------------
-- Create some helper funcs and build up a hex grid  
-- ulx=-77.187113
-- lrx=-76.696774
-- lry=39.103142
-- uly=39.369323
----------------------------------------------------------------------- 

-----------------------------------------------------------------------
-- This is the heat map grid per deer, per day, per hex grid. 
-- It would be good to have the grid size be an env variable. 
-- https://stackoverflow.com/questions/72608601/how-to-pass-variable-to-init-sql-file-from-docker-entrypoint-initdb-d
-----------------------------------------------------------------------  
CREATE MATERIALIZED VIEW IF NOT EXISTS geo.hex_grid
AS
 WITH gps_extent AS (
         SELECT  ST_Transform(ST_SetSRID(ST_MakeEnvelope(-77.2, 39.37, -76.69, 39.1),4326),26918) as geom
        ), hex AS (
         SELECT (st_hexagongrid(60::double precision, gps_extent.geom::geometry)).geom AS geom,
            (st_hexagongrid(60::double precision, gps_extent.geom::geometry)).i AS i,
            (st_hexagongrid(60::double precision, gps_extent.geom::geometry)).j AS j
           FROM gps_extent
        )
 SELECT 
	 row_number() OVER () AS gid,
     ST_Transform(geom,4326) AS geom
   FROM hex
WITH DATA;

CREATE INDEX hex_grid_ix
   ON geo.hex_grid USING gist (geom);

----------------------------------------------------------------------
-- Hex Grid Products:
-- if it aligns to the hex-grid then it's gonna get placed here. 
----------------------------------------------------------------------

CREATE MATERIALIZED VIEW IF NOT EXISTS gps.heatmap_hex_grid
TABLESPACE pg_default
AS
 SELECT grid.gid,
    traj.deer_id,
    traj.date,
    count(traj.lag_segment) AS track_count,
	 avg((traj.lag_geom_delta_meters)/(EXTRACT(epoch FROM traj.lag_time_delta)/3600)) AS avg_speed,
    sum(st_length(st_intersection(traj.lag_segment, grid.geom)) * EXTRACT(epoch FROM traj.lag_time_delta)::double precision / traj.lag_geom_delta) AS cum_time_in_grid
   FROM geo.hex_grid grid
     JOIN gps.lead_lag_positions traj ON st_intersects(traj.lag_segment, grid.geom)
  WHERE traj.lag_geom_delta_meters > 0::double precision
  GROUP BY grid.gid, traj.deer_id, traj.date
WITH DATA;

ALTER TABLE IF EXISTS gps.heatmap_hex_grid
    OWNER TO gmu;

GRANT SELECT ON TABLE gps.heatmap_hex_grid TO api;
GRANT ALL ON TABLE gps.heatmap_hex_grid TO gmu;

CREATE INDEX heat_grid_ix
    ON gps.heatmap_hex_grid USING btree
    (deer_id, date, gid)
    TABLESPACE pg_default;

----------------------------------------------------------------------
-- TOD Hex Heatmap
----------------------------------------------------------------------
CREATE MATERIALIZED VIEW IF NOT EXISTS gps.heatmap_hex_grid_hourly
TABLESPACE pg_default
AS
 SELECT grid.gid,
    traj.deer_id,
    EXTRACT(hour FROM traj."timestamp") AS hour_of_day,
    count(traj.lag_segment) AS track_count,
    sum(st_length(st_intersection(traj.lag_segment, grid.geom)) * EXTRACT(epoch FROM traj.lag_time_delta)::double precision / traj.lag_geom_delta) AS cum_time_in_grid
   FROM geo.hex_grid grid
     JOIN gps.lead_lag_positions traj ON st_intersects(traj.lag_segment, grid.geom)
  WHERE traj.lag_geom_delta_meters > 0::double precision
  GROUP BY grid.gid, traj.deer_id, (EXTRACT(hour FROM traj."timestamp"))
WITH DATA;

ALTER TABLE IF EXISTS gps.heatmap_hex_grid_hourly
    OWNER TO gmu;

GRANT SELECT ON TABLE gps.heatmap_hex_grid_hourly TO api;
GRANT ALL ON TABLE gps.heatmap_hex_grid_hourly TO gmu;

-----------------------------------------------------------------------
-- NLCD LandCover Classes from https://www.mrlc.gov/data/legends/national-land-cover-database-class-legend-and-description
-----------------------------------------------------------------------
CREATE TABLE geo.land_cover_classes (
    id integer primary key,
    class text,
    subclass text,
    description text);

COPY geo.land_cover_classes ("id","class","subclass","description")
FROM '/tmp/db_init_data/land_cover_classes.csv' DELIMITER ',' CSV HEADER;

-----------------------------------------------------------------------
-----------------------------------------------------------------------

