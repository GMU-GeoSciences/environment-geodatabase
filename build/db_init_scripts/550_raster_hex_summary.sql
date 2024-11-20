 
-----------------------------------------------------------------------
-- Raster Hex Summary:
--  Summary values for the different raster/vector/landcover datasets
--  loaded in previous scripts. 
-----------------------------------------------------------------------  

-----------------------------------------------------------------------
-- Canopy View
----------------------------------------------------------------------- 
CREATE VIEW geo.canopy_hex_summary
AS
 WITH clipped_tiles AS (
         SELECT st_clip(srtm.rast, st_transform(hex.geom, 4326), -1) AS rast,
            srtm.rid,
            hex.gid
           FROM geo.canopy srtm
             JOIN geo.hex_grid hex ON st_intersects(st_transform(hex.geom, 4326), st_convexhull(srtm.rast))
        )
 SELECT gid,
    (st_summarystatsagg(rast, 1, true)).count AS count,
    (st_summarystatsagg(rast, 1, true)).sum AS sum,
    (st_summarystatsagg(rast, 1, true)).mean AS mean,
    (st_summarystatsagg(rast, 1, true)).stddev AS stddev,
    (st_summarystatsagg(rast, 1, true)).min AS min,
    (st_summarystatsagg(rast, 1, true)).max AS max
   FROM clipped_tiles
  GROUP BY gid;

-----------------------------------------------------------------------
-- Impervious Surfaces
----------------------------------------------------------------------- 
CREATE VIEW geo.surface_hex_summary
AS
 WITH clipped_tiles AS (
         SELECT st_clip(srtm.rast, st_transform(hex.geom, 4326), -1) AS rast,
            srtm.rid,
            hex.gid
           FROM geo.surface srtm
             JOIN geo.hex_grid hex ON st_intersects(st_transform(hex.geom, 4326), st_convexhull(srtm.rast))
        )
 SELECT gid,
    (st_summarystatsagg(rast, 1, true)).count AS count,
    (st_summarystatsagg(rast, 1, true)).sum AS sum,
    (st_summarystatsagg(rast, 1, true)).mean AS mean,
    (st_summarystatsagg(rast, 1, true)).stddev AS stddev,
    (st_summarystatsagg(rast, 1, true)).min AS min,
    (st_summarystatsagg(rast, 1, true)).max AS max
   FROM clipped_tiles
   GROUP BY gid;

-----------------------------------------------------------------------
-- Landcover View (A wee bit different...)
----------------------------------------------------------------------- 
CREATE VIEW geo.landcover_hex_grid_summary 
AS 
WITH pixel_vars AS
	(
	SELECT 
		ST_ValueCount(st_clip(srtm.rast, st_transform(hex.geom, 4326), '-1'::integer::double precision))  AS rast_values, 
		srtm.rid,
		hex.gid
	FROM geo.landcover srtm
	JOIN geo.hex_grid hex ON st_intersects(st_transform(hex.geom, 4326), st_convexhull(srtm.rast))) 
Select 
	gid,
	land_cover_classes.class, 
	land_cover_classes.subclass,
	(rast_values).*
FROM pixel_vars
JOIN geo.land_cover_classes 
ON (rast_values).value = land_cover_classes.id;

-----------------------------------------------------------------------
-- OSM Hex Summaries
----------------------------------------------------------------------- 

CREATE MATERIALIZED VIEW IF NOT EXISTS osm.built_area_hex_summary
TABLESPACE pg_default
AS
 SELECT 
    row_number() OVER () AS id,
    hex.gid,
    hex.geom,
    sum(st_area(st_intersection(st_transform(hex.geom, 3857), osm.way))) AS built_area
   FROM planet_osm_polygon osm
     RIGHT JOIN geo.hex_grid hex ON st_intersects(osm.way, st_transform(hex.geom, 3857))
  WHERE osm.building IS NOT NULL
  GROUP BY hex.gid, hex.geom
WITH DATA;

ALTER TABLE IF EXISTS osm.built_area_hex_summary
    OWNER TO gmu;

-----------------------------------------------------------------------
--
----------------------------------------------------------------------- 

CREATE MATERIALIZED VIEW IF NOT EXISTS osm.highway_length_hex_summary
TABLESPACE pg_default
AS
 SELECT 
    row_number() OVER () AS id,
    hex.gid,
    hex.geom,
    sum(st_length(st_intersection(st_transform(hex.geom, 3857), osm.way))) AS highway_length
   FROM planet_osm_roads osm
     RIGHT JOIN geo.hex_grid hex ON st_intersects(osm.way, st_transform(hex.geom, 3857))
  GROUP BY hex.gid, hex.geom
WITH DATA;

ALTER TABLE IF EXISTS osm.highway_length_hex_summary
    OWNER TO gmu;
-----------------------------------------------------------------------
--
----------------------------------------------------------------------- 

CREATE MATERIALIZED VIEW IF NOT EXISTS osm.asphalt_length_hex_summary
TABLESPACE pg_default
AS
 SELECT 
    row_number() OVER () AS id,
    hex.gid,
    hex.geom,
    sum(st_length(st_intersection(st_transform(hex.geom, 3857), osm.way))) AS asphalt_length
   FROM planet_osm_line osm
     RIGHT JOIN geo.hex_grid hex ON st_intersects(osm.way, st_transform(hex.geom, 3857))
  WHERE osm.surface = 'asphalt'::text
  GROUP BY hex.gid, hex.geom
WITH DATA;

ALTER TABLE IF EXISTS osm.asphalt_length_hex_summary
    OWNER TO gmu;

-----------------------------------------------------------------------
--
----------------------------------------------------------------------- 

CREATE MATERIALIZED VIEW IF NOT EXISTS pop.population_hex_summary
TABLESPACE pg_default
AS
SELECT 
   hex.gid as gid, 
   sum(pop."Total_2020") AS pop_total
FROM pop.high_res_pop pop
   RIGHT JOIN geo.hex_grid hex ON st_within(pop.geometry, st_transform(hex.geom, 4326))
GROUP BY hex.gid, hex.geom
WITH DATA;

ALTER TABLE IF EXISTS osm.asphalt_length_hex_summary
    OWNER TO gmu;

 