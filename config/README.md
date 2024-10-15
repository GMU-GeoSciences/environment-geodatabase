# Config Files

This folder contains the config files required to get the spatial database up and running:

* **feat_serv_config.toml** : [The config file for pg_feature_serv](https://access.crunchydata.com/documentation/pg_featureserv/1.3.1/installation/configuration/)
* **postgresql.conf** : Postgres config file. This generally gets overwritten by TimeScaleDB on the first run. But it's here just in case.
* **sample.env** : Environment variables that configure the docker-compose.yaml file and the containers within. It must get renamed as .env and copied to be in the root dir of this project in order for docker-compose to see it. 

```
#----------------------
#Project
#----------------------
UID=1000
GID=1000
#----------------------

#----------------------
# Database with Postgis and TimescaleDB
#----------------------
#This should be changed to reflect the Host Machines Name.
DB_HOST=db_host
DB_NAME=deer
DB_EXT_PORT=5555
DB_INT_PORT=5432

# these should be docker secrets...
POSTGRES_USER=gmu
POSTGRES_DB=deer
POSTGRES_PASSWORD=super_secret_password
# FETCH_GEOM == "False" will result in no geometry being downloaded on DB init. 
FETCH_GEOM=True
#----------------------
PGFEATSERV_TAG=latest
API_PORT=9999
API_USER=api
API_PW=super_secret_password
#----------------------
```
In this file are the following variables:


| ENV Variable | Description |  
| --- | --- |  
| UID | Linux User ID. Used to control read/write permissions for docker mount |  
| GID | Linux Group ID. Used to control read/write permissions for docker mount |
| DB_HOST | Not Used |
| DB_NAME | Not Used |
| DB_EXT_PORT | External port that Docker should mount to container port |
| DB_INT_PORT | Internal container port. Should be Postgres standard of 5432 |
| POSTGRES_USER | Username for DB user | 
| POSTGRES_DB  | Database name in Postgres | 
| POSTGRES_PASSWORD | Default password. Should probably change this on deployment | 
| FETCH_GEOM | Controls whether large geoms are downloaded on DB creation | 
| PGFEATSERV_TAG | [Docker Tag](https://hub.docker.com/r/pramsey/pg_featureserv/tags) | 
| API_PORT | Port for Docker to mount PgFeatServ container | 
| API_USER | API user to query DB | 
| API_PW | API user password | 


