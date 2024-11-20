-- Create roles for new users and assign them the the users
-- Users should include
--   admin user: These users can do anything
--   write user: can only write to certain schemas
--   API data reader: can only read from certain schemas

CREATE USER api WITH PASSWORD 'same_password_in_build_files' LOGIN;
GRANT USAGE ON SCHEMA postgisftw TO api;
GRANT USAGE ON SCHEMA gps TO api; 
GRANT SELECT ON ALL TABLES IN SCHEMA postgisftw TO api;
GRANT SELECT ON ALL TABLES IN SCHEMA gps TO api;
ALTER DEFAULT PRIVILEGES IN SCHEMA postgisftw GRANT SELECT ON TABLES TO api;
ALTER DEFAULT PRIVILEGES IN SCHEMA gps GRANT SELECT ON TABLES TO api;
