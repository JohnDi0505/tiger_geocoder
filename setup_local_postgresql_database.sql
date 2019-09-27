CREATE EXTENSION address_standardizer;
CREATE EXTENSION fuzzystrmatch;
CREATE EXTENSION ogr_fdw;
CREATE EXTENSION pgrouting;
CREATE EXTENSION plpgsql;
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_sfcgal;
CREATE EXTENSION postgis_tiger_geocoder;
CREATE EXTENSION postgis_topology;

CREATE TABLE geocd_nj (
	ticket INT PRIMARY KEY,
	dt DATE NOT NULL,
	tm TIME NOT NULL,
	rating SMALLINT,
	hder VARCHAR (20),
	lon DOUBLE PRECISION,
	lat DOUBLE PRECISION,
	st_no SMALLINT,
	st_nm VARCHAR (50),
	city VARCHAR (50),
	county VARCHAR (50),
	state_nm VARCHAR (5),
	zip VARCHAR (5),
	excav_comp VARCHAR (50),
	inter1 VARCHAR (50),
	inter2 VARCHAR (50)
);

INSERT INTO geocd_nj (ticket, dt, tm, hder, county, excav_comp, inter1, inter2)
	
	VALUES (100600001,'2010-03-01', '02:51:21-05', 'EMERGENCY', 'BERGEN', 'ORANGE AND ROCKLAND UTILITIES', 'HARING FARM', NULL)
;

UPDATE geocd_nj
	SET 
	rating = g.rating, lon = ST_X(g.geomout),lat = ST_Y(g.geomout),
    st_no = (addy).address,st_nm = (addy).streetname,
    city = (addy).location,state_nm = (addy).stateabbrev,zip = (addy).zip
	FROM geocode('9 PIERMONT, ROCKLEIGH, NJ', 1) As g
	
	WHERE ticket = 100600001
;

# Sample geocoding query
SELECT g.rating, ST_X(g.geomout), ST_Y(g.geomout), (addy).address, (addy).streetname, (addy).location, (addy).stateabbrev, (addy).zip FROM geocode('55 Bevier Rd, Piscataway, NJ 08854', 1) As g;
