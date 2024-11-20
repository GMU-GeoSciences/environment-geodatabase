CREATE MATERIALIZED VIEW IF NOT EXISTS postgisftw.hex_environmental_features_30m
TABLESPACE pg_default
AS

WITH 
	hex_grid       as (SELECT * FROM geo.hex_grid),
	canopy_summary as ( WITH clipped_tiles AS (
							 SELECT st_clip(srtm.rast, st_transform(hex.geom, 4326)) AS rast,
						            srtm.rid,
						            hex.gid,
									hex.geom
						           FROM geo.canopy srtm
						             JOIN hex_grid hex ON st_intersects(st_transform(hex.geom, 4326), st_convexhull(srtm.rast))
						        )
						 SELECT gid, 
						 	geom,
						    (st_summarystatsagg(rast, 1, true)).count AS canopy_count,
						    (st_summarystatsagg(rast, 1, true)).sum AS canopy_sum,
						    (st_summarystatsagg(rast, 1, true)).mean AS canopy_mean,
						    (st_summarystatsagg(rast, 1, true)).stddev AS canopy_stddev,
						    (st_summarystatsagg(rast, 1, true)).min AS canopy_min,
						    (st_summarystatsagg(rast, 1, true)).max AS canopy_max
						   FROM clipped_tiles
						  GROUP BY gid, geom),
	imperv_summary as (WITH clipped_tiles AS (
							 SELECT st_clip(srtm.rast, st_transform(hex.geom, 4326)) AS rast,
								srtm.rid,
								hex.gid,
						 		hex.geom
							   FROM geo.surface srtm
								 JOIN hex_grid hex ON st_intersects(st_transform(hex.geom, 4326), st_convexhull(srtm.rast))
							)
					 SELECT gid,
						 	geom,
						(st_summarystatsagg(rast, 1, true)).count AS surface_count,
						(st_summarystatsagg(rast, 1, true)).sum AS surface_sum,
						(st_summarystatsagg(rast, 1, true)).mean AS surface_mean,
						(st_summarystatsagg(rast, 1, true)).stddev AS surface_stddev,
						(st_summarystatsagg(rast, 1, true)).min AS surface_min,
						(st_summarystatsagg(rast, 1, true)).max AS surface_max
					   FROM clipped_tiles
					   GROUP BY gid, geom),
	osm_building   as (SELECT row_number() OVER () AS id,
						    hex.gid, 
						    sum(st_area(st_intersection(st_transform(hex.geom, 3857), osm.way))) AS built_area
						   FROM planet_osm_polygon osm
						     RIGHT JOIN hex_grid hex ON st_intersects(osm.way, st_transform(hex.geom, 3857))
						  WHERE osm.building IS NOT NULL
						  GROUP BY hex.gid, hex.geom),
	osm_roads      as (SELECT row_number() OVER () AS id,
						    hex.gid, 
						    sum(st_length(st_intersection(st_transform(hex.geom, 3857), osm.way))) AS asphalt_length
						   FROM planet_osm_line osm
						     RIGHT JOIN hex_grid hex ON st_intersects(osm.way, st_transform(hex.geom, 3857))
						  WHERE osm.surface = 'asphalt'::text
						  GROUP BY hex.gid, hex.geom),
	osm_highways   as (SELECT row_number() OVER () AS id,
					    hex.gid, 
					    sum(st_length(st_intersection(st_transform(hex.geom, 3857), osm.way))) AS highway_length
					   FROM planet_osm_roads osm
					     RIGHT JOIN hex_grid hex ON st_intersects(osm.way, st_transform(hex.geom, 3857))
					  GROUP BY hex.gid, hex.geom),
	pop_summary    as (SELECT hex.gid, 
					    sum(pop."Total_2020") AS pop_total
					   FROM pop.high_res_pop pop
					     RIGHT JOIN hex_grid hex ON st_within(pop.geometry, st_transform(hex.geom, 4326))
					  GROUP BY hex.gid, hex.geom),
	forest_clusts  as (WITH clusters AS (
						         SELECT DISTINCT ON (hex_heatmap_ml_features.hex_id) hex_heatmap_ml_features.hex_id,
						            hex_heatmap_ml_features.geom,
						            st_clusterdbscan(st_transform(hex_heatmap_ml_features.geom, 26918), eps => 110::double precision, minpoints => 2) OVER () AS cid
						           FROM canopy_summary
						          WHERE canopy_summary.canopy_mean > 40::double precision
						        ), cluster_count AS (
						         SELECT clusters_1.cid,
						            count(clusters_1.cid) AS count
						           FROM clusters clusters_1
						          GROUP BY clusters_1.cid
						        )
						 SELECT clusters.hex_id, 
						    clusters.forest_cluster_cid,
						    cluster_count.forest_cluster_count
						   FROM clusters
						     JOIN cluster_count ON clusters.cid = cluster_count.cid),
	imperv_clusts  as (WITH clusters AS (
						         SELECT DISTINCT ON (hex_heatmap_ml_features.hex_id) hex_heatmap_ml_features.hex_id,
						            hex_heatmap_ml_features.geom,
						            st_clusterdbscan(st_transform(hex_heatmap_ml_features.geom, 26918), eps => 110::double precision, minpoints => 2) OVER () AS cid
						           FROM postgisftw.hex_heatmap_ml_features
						          WHERE hex_heatmap_ml_features.imperv_mean > 20::double precision
						        ), cluster_count AS (
						         SELECT clusters_1.cid,
						            count(clusters_1.cid) AS count
						           FROM clusters clusters_1
						          GROUP BY clusters_1.cid
						        )
						 SELECT clusters.hex_id, 
						    clusters.imperv_cluster_cid,
						    cluster_count.imperv_cluster_count
						   FROM clusters
						     JOIN cluster_count ON clusters.cid = cluster_count.cid)
SELECT 
	row_number() OVER () AS id,
	hex_grid.hex_id as gid,
	hex_grid.geom::geometry(Polygon,4326) as geom,
	canopy_summary.*,
	imperv_summary.*,
	osm_building.*,
	osm_roads.*,
	osm_highways.*,
	pop_summary.*,
	forest_clusts.*,
	imperv_clusts.*
FROM hex_grid
LEFT JOIN canopy_summary ON hex_grid.gid = canopy_summary.gid
LEFT JOIN imperv_summary ON hex_grid.gid = imperv_summary.gid
LEFT JOIN osm_building   ON hex_grid.gid = osm_building.gid
LEFT JOIN osm_roads      ON hex_grid.gid = osm_roads.gid
LEFT JOIN osm_highways   ON hex_grid.gid = osm_highways.gid
LEFT JOIN pop_summary    ON hex_grid.gid = pop_summary.gid
LEFT JOIN forest_clusts  ON hex_grid.gid = forest_clusts.gid
LEFT JOIN imperv_clusts  ON hex_grid.gid = imperv_clusts.gid
WITH DATA;