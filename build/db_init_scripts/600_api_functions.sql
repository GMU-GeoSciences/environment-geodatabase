
/*
Scripts to create views in postgisftw schema that will be used by pg_featureserv API
*/

--------------------------------------------------------------------------------------------------
-- BASIC DATA
-------------------------------------------------------------------------------------------------- 
--------------------------------------------------------------------------------------------------
-- 2019 Census Block Data
--------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW postgisftw.census_block_2019
 AS
 SELECT 
	gid,
	statefp,
	countyfp,
	tractce,
	blkgrpce,
	affgeoid,
	geoid,
	name,
	lsad,
	aland,
	awater,
	geom::geometry(MultiPolygon,4269) as geom 
 FROM geo.maryland_census_blocks_2019;

COMMENT ON VIEW postgisftw.census_block_2019 IS '2019 Census Block data from https://www2.census.gov/geo/tiger/GENZ2019/';

--------------------------------------------------------------------------------------------------
-- 2023 Census Block Data
--------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW postgisftw.census_block_2023
 AS
 SELECT 
	gid,
	statefp,
	countyfp,
	tractce,
	blkgrpce,
	geoidfq,
	geoid,
	name,
	lsad,
	aland,
	awater,
	geom::geometry(MultiPolygon,4269) as geom 
 FROM geo.maryland_census_blocks_2023;

COMMENT ON VIEW postgisftw.census_block_2023 IS '2023 Census Block data from https://www2.census.gov/geo/tiger/GENZ2023/';


--------------------------------------------------------------------------------------------------
-- Open Street Map
--------------------------------------------------------------------------------------------------
 
CREATE VIEW  postgisftw.osm_building_area 
AS
 SELECT 
 	osm.*
   FROM planet_osm_polygon osm 
  WHERE osm.building IS NOT NULL ;
 
COMMENT ON VIEW postgisftw.osm_building_area IS 'Building Polygons from OSM';


--------------------------------------------------------------------------------------------------
-- Meta High Res Population
--------------------------------------------------------------------------------------------------
 
CREATE VIEW  postgisftw.meta_high_res_population
AS
 SELECT 
 	pop.*
   FROM pop.high_res_pop as pop;

COMMENT ON VIEW postgisftw.meta_high_res_population IS 'Population data from https://dataforgood.facebook.com/dfg/docs/methodology-high-resolution-population-density-maps';

 

--------------------------------------------------------------------------------------------------
-- Environmental Features
--------------------------------------------------------------------------------------------------

CREATE MATERIALIZED VIEW IF NOT EXISTS postgisftw.hex_environmental_features_30m
TABLESPACE pg_default
AS
SELECT 
	row_number() OVER () AS id,
	hex_grid.gid as gid,
	hex_grid.geom::geometry(Polygon,4326) as geom,
	canopy_hex_summary.mean as canopy_mean,
	canopy_hex_summary.max as canopy_max,
	canopy_hex_summary.min as canopy_min,
	canopy_hex_summary.stddev as canopy_stddev,

	surface_hex_summary.mean as surface_mean,
	surface_hex_summary.max as surface_max,
	surface_hex_summary.min as surface_min,
	surface_hex_summary.stddev as surface_stddev,

	built_area_hex_summary.built_area,
	asphalt_length_hex_summary.asphalt_length,
	highway_length_hex_summary.highway_length,
	population_hex_summary.pop_total
	-- annual_raw_visit_counts_kde_2018.kde as kde_2018
 
FROM geo.hex_grid
LEFT JOIN geo.canopy_hex_summary         ON hex_grid.gid = canopy_hex_summary.gid
LEFT JOIN geo.surface_hex_summary        ON hex_grid.gid = surface_hex_summary.gid
LEFT JOIN osm.built_area_hex_summary     ON hex_grid.gid = built_area_hex_summary.gid
LEFT JOIN osm.asphalt_length_hex_summary ON hex_grid.gid = asphalt_length_hex_summary.gid
LEFT JOIN osm.highway_length_hex_summary ON hex_grid.gid = highway_length_hex_summary.gid
LEFT JOIN pop.population_hex_summary     ON hex_grid.gid = population_hex_summary.gid
-- LEFT JOIN pop.annual_raw_visit_counts_kde_2018  ON hex_grid.gid = annual_raw_visit_counts_kde_2018.gid
ORDER BY gid
WITH DATA;
