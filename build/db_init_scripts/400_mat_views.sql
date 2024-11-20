----------------------------------------------------------------------
-- Create some views on the GPS table that might be helpful
--   - Lead/Lag between GPS points
--   - Convex Hull/Cluster of the points per individual


-- NOTE: These views will need to be refreshed once data is in 
-- inserted into tables. Either new data or if the original data 
-- isn't inserted during DB gen
----------------------------------------------------------------------


----------------------------------------------------------------------
-- Lead Lag
-- Works, but is slow and needs some work.
----------------------------------------------------------------------
CREATE MATERIALIZED VIEW gps.lead_lag_positions 
AS
 SELECT 
	deer_id,
    date("timestamp") AS date,
    "timestamp",
    geom,
    (gps.gps_dop < 10) as gps_dop_below_10, -- https://www.tersus-gnss.com/tech_blog/what-is-dop-in-gnss
    -- Lag
    st_makeline(geom, lag(geom) OVER (PARTITION BY deer_id ORDER BY "timestamp")) AS lag_segment,
    "timestamp" - lag("timestamp") OVER (PARTITION BY deer_id ORDER BY "timestamp") AS lag_time_delta,
    st_distance(geom, lag(geom) OVER (PARTITION BY deer_id ORDER BY "timestamp")) AS lag_geom_delta,
    st_distance(st_transform(geom, 26918), lag(st_transform(geom, 26918)) OVER (PARTITION BY deer_id ORDER BY "timestamp")) AS lag_geom_delta_meters,
    -- Lead
    st_makeline(lead(geom) OVER (PARTITION BY deer_id ORDER BY "timestamp"), geom ) AS lead_segment,
    lead("timestamp") OVER (PARTITION BY deer_id ORDER BY "timestamp") - "timestamp"  AS lead_time_delta,
    st_distance(lead(geom) OVER (PARTITION BY deer_id ORDER BY "timestamp"), geom ) AS lead_geom_delta,
    st_distance(lead(st_transform(geom, 26918)) OVER (PARTITION BY deer_id ORDER BY "timestamp"), st_transform(geom, 26918) ) AS lead_geom_delta_meters,
    -- Lead/Lag Deltas
    ST_Angle(lag(geom) OVER (PARTITION BY deer_id ORDER BY "timestamp"), geom, lead(geom) OVER (PARTITION BY deer_id ORDER BY "timestamp")) as turning_angle

   FROM gps.gps 
ORDER BY timestamp desc;

-- CREATE INDEX ON wrd USING GIST (gps_dop_below_10);
CREATE INDEX ON gps.lead_lag_positions USING GIST (geom); 
CREATE INDEX ON gps.lead_lag_positions (deer_id, timestamp, gps_dop_below_10); 
----------------------------------------------------------------------
-- Home Range. Works. Also slow... Might need to index gps_dop or derive a value for it
----------------------------------------------------------------------
-- Create or replace view deer.monthly_hull as 
Create Materialized view gps.monthly_hull as 
SELECT 
    gps.deer_id,  
    date_part('year', gps.timestamp) as year,
    date_part('month', gps.timestamp) as month, 
	-- ST_ConcaveHull(ST_Collect(gps.geom), 0.3) as geom
	ST_ConvexHull(ST_Collect(gps.geom)) as geom
FROM
	gps.lead_lag_positions as gps
WHERE gps.gps_dop_below_10 = true
GROUP BY gps.deer_id, date_part('year', gps.timestamp), date_part('month', gps.timestamp);


----------------------------------------------------------------------
----------------------------------------------------------------------
