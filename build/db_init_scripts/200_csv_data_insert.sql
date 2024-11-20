----------------------------------------------------------------------
-- Load some data from CSV's
----------------------------------------------------------------------

-- BEGIN;

-- CREATE TEMP TABLE tmp AS SELECT * FROM target_table LIMIT 0;
-- ALTER TABLE tmp ADD COLUMN etra_column1 text
--              ,  ADD COLUMN etra_column2 text;  -- add excess columns
-- COPY tmp FROM '/path/tp/file.csv';

-- INSERT INTO target_table (col1, col2, col3)
-- SELECT col1, col2, col3 FROM tmp  -- only reelvant columns
-- WHERE  ...  -- optional, to also filter rows

-- COPY deer.gps (ais_num, description, type, sub_type, abrv)
-- FROM '/tmp/db_init_data/ais_nums.csv' DELIMITER ',' CSV HEADER;

-- COPY deer.individuals (collar,collar_ID,deer_id,sex,age_at_deployment,park_name,notes)
-- FROM '/tmp/db_init_data/Individuals.csv' DELIMITER ',' CSV HEADER;

-- COMMIT;

---------------------------------------------------------------------- 
----------------------------------------------------------------------
