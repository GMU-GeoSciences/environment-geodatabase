----------------------------------------------------------------------
-- Load some AIS helper tables from CSV's
-- BEGIN;
-- CREATE TABLE ais.ais_num_to_type
-- (
--     ais_num character varying(3) COLLATE pg_catalog."default" NOT NULL,
--     description text COLLATE pg_catalog."default",
--     type text COLLATE pg_catalog."default",
--     sub_type text COLLATE pg_catalog."default",
--     abrv character varying(3) COLLATE pg_catalog."default" NOT NULL
-- );

-- COPY ais.ais_num_to_type (ais_num, description, type, sub_type, abrv)
-- FROM '/tmp/db_init_data/ais_nums.csv' DELIMITER ',' CSV HEADER;

-- CREATE TABLE ais.nav_status
-- (
--     nav_status text COLLATE pg_catalog."default",
--     description text COLLATE pg_catalog."default"
-- );
-- COPY ais.nav_status (nav_status, description)
-- FROM '/tmp/db_init_data/nav_status.csv' DELIMITER ',' CSV HEADER;

-- CREATE TABLE ais.mid_to_country
-- (
--     country text COLLATE pg_catalog."default" NOT NULL,
--     country_abrv0 text COLLATE pg_catalog."default",
--     country_abrv1 text COLLATE pg_catalog."default",
--     country_abrv2 text COLLATE pg_catalog."default",
--     mid character varying(3) COLLATE pg_catalog."default" NOT NULL,
--     flag_link text COLLATE pg_catalog."default"    
-- );
-- COPY ais.mid_to_country (mid, country_abrv0, country_abrv1, country_abrv2, country, flag_link)
-- FROM '/tmp/db_init_data/mids.csv' DELIMITER ',' CSV HEADER;

-- COMMIT;
-- COMMENT ON TABLE ais.ais_num_to_type IS 'Lookup table to store AIS Type and Cargo Code, from AIS protocol.';
-- COMMENT ON TABLE ais.mid_to_country IS 'Lookup table to store Country Codes; first 3 digits of MMSI.';
-- COMMENT ON TABLE ais.nav_status IS 'Lookup table to store Nav Status Code, from AIS protocol.';
