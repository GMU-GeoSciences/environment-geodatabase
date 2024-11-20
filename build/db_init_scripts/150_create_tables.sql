----------------------------------------------------------------------
-- Create some tables to insert GPS and individual data 
----------------------------------------------------------------------
----------------------------------------------------------------------
BEGIN;

CREATE TABLE IF NOT EXISTS gps.individuals
(
    deer_id	integer primary key,
    collar text,
    collar_ID  text,
    sex	 text,
    age_at_deployment float,	
    park_name  text,
    notes  text    
);

----------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS gps.gps
(  
    event_id bigint,-- primary key,
    "timestamp" timestamptz NOT NULL,
    geom geometry(Point,4326),
    deer_id integer references gps.individuals(deer_id),
    tag_id text,
    external_temp numeric,
    gps_dop numeric,
    height_above_ellipsoid numeric
);
-- Need to delete primary keys that pgsql stuck on table. Best to just create data from raw tables
SELECT create_hypertable('gps.gps', by_range('timestamp') );

CREATE UNIQUE INDEX event_id_timestamp ON gps.gps(event_id, timestamp);
 
COMMIT;

COMMENT ON TABLE gps.gps IS 'GPS positions for deer collars.';
COMMENT ON TABLE gps.individuals IS 'Individual deer information.'; 
----------------------------------------------------------------------
-- Human population tables
----------------------------------------------------------------------  
 
CREATE TABLE IF NOT EXISTS pop.high_res_pop
(
    latitude double precision,
    longitude double precision,
    "USA_children_under_five_2020-03-07" double precision,
    "USA_elderly_60_plus_2020-03-07" double precision,
    "USA_men_2020-03-07" double precision,
    "USA_total_2019-07-01" double precision,
    "USA_women_2020-03-07" double precision,
    "USA_youth_15_24_2020-03-07" double precision,
    "Total_2020" double precision,
    geometry geometry(Point,4326)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS pop.high_res_pop
    OWNER to gmu;
-- Index: idx_pop_geometry

-- DROP INDEX IF EXISTS geo.idx_pop_geometry;

CREATE INDEX IF NOT EXISTS idx_pop_geometry
    ON pop.high_res_pop USING gist
    (geometry)
    TABLESPACE pg_default;

----------------------------------------------------------------------
----------------------------------------------------------------------  