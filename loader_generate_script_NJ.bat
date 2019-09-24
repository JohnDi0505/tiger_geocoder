set TMPDIR=C:\gisdata
set UNZIPTOOL="C:\Program Files\7-Zip\7z.exe"
set WGETTOOL="C:\wget\wget.exe"
set PGBIN=C:\Program Files\PostgreSQL\11\bin\
set PGPORT=5432
set PGHOST=localhost
set PGUSER=postgres
set PGPASSWORD=postgres
set PGDATABASE=geocoder
set PSQL="%PGBIN%psql"
set SHP2PGSQL="%PGBIN%shp2pgsql"
cd \gisdata

cd \gisdata
%WGETTOOL% https://www2.census.gov/geo/tiger/TIGER2017/PLACE/tl_2017_34_place.zip --mirror --reject=html
cd \gisdata/www2.census.gov/geo/tiger/TIGER2017/PLACE
del %TMPDIR%\*.* /Q
%PSQL% -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
%PSQL% -c "CREATE SCHEMA tiger_staging;"
%PSQL% -c "DO language 'plpgsql' $$ BEGIN IF NOT EXISTS (SELECT * FROM information_schema.schemata WHERE schema_name = 'tiger_data' ) THEN CREATE SCHEMA tiger_data; END IF;  END $$"
for /r %z in (tl_2017_34*_place.zip ) do %UNZIPTOOL% e %z  -o%TMPDIR%
cd %TMPDIR%
%PSQL% -c "CREATE TABLE tiger_data.NJ_place(CONSTRAINT pk_NJ_place PRIMARY KEY (plcidfp) ) INHERITS(tiger.place);" 
%SHP2PGSQL% -D -c -s 4269 -g the_geom   -W "latin1" tl_2017_34_place.dbf tiger_staging.nj_place | %PSQL%
%PSQL% -c "ALTER TABLE tiger_staging.NJ_place RENAME geoid TO plcidfp;SELECT loader_load_staged_data(lower('NJ_place'), lower('NJ_place')); ALTER TABLE tiger_data.NJ_place ADD CONSTRAINT uidx_NJ_place_gid UNIQUE (gid);"
%PSQL% -c "CREATE INDEX idx_NJ_place_soundex_name ON tiger_data.NJ_place USING btree (soundex(name));"
%PSQL% -c "CREATE INDEX tiger_data_NJ_place_the_geom_gist ON tiger_data.NJ_place USING gist(the_geom);"
%PSQL% -c "ALTER TABLE tiger_data.NJ_place ADD CONSTRAINT chk_statefp CHECK (statefp = '34');"
cd \gisdata
%WGETTOOL% https://www2.census.gov/geo/tiger/TIGER2017/COUSUB/tl_2017_34_cousub.zip --mirror --reject=html
cd \gisdata/www2.census.gov/geo/tiger/TIGER2017/COUSUB
del %TMPDIR%\*.* /Q
%PSQL% -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
%PSQL% -c "CREATE SCHEMA tiger_staging;"
%PSQL% -c "DO language 'plpgsql' $$ BEGIN IF NOT EXISTS (SELECT * FROM information_schema.schemata WHERE schema_name = 'tiger_data' ) THEN CREATE SCHEMA tiger_data; END IF;  END $$"
for /r %z in (tl_2017_34*_cousub.zip ) do %UNZIPTOOL% e %z  -o%TMPDIR%
cd %TMPDIR%
%PSQL% -c "CREATE TABLE tiger_data.NJ_cousub(CONSTRAINT pk_NJ_cousub PRIMARY KEY (cosbidfp), CONSTRAINT uidx_NJ_cousub_gid UNIQUE (gid)) INHERITS(tiger.cousub);" 
%SHP2PGSQL% -D -c -s 4269 -g the_geom   -W "latin1" tl_2017_34_cousub.dbf tiger_staging.nj_cousub | %PSQL%
%PSQL% -c "ALTER TABLE tiger_staging.NJ_cousub RENAME geoid TO cosbidfp;SELECT loader_load_staged_data(lower('NJ_cousub'), lower('NJ_cousub')); ALTER TABLE tiger_data.NJ_cousub ADD CONSTRAINT chk_statefp CHECK (statefp = '34');"
%PSQL% -c "CREATE INDEX tiger_data_NJ_cousub_the_geom_gist ON tiger_data.NJ_cousub USING gist(the_geom);"
%PSQL% -c "CREATE INDEX idx_tiger_data_NJ_cousub_countyfp ON tiger_data.NJ_cousub USING btree(countyfp);"
cd \gisdata
%WGETTOOL% https://www2.census.gov/geo/tiger/TIGER2017/TRACT/tl_2017_34_tract.zip --mirror --reject=html
cd \gisdata/www2.census.gov/geo/tiger/TIGER2017/TRACT
del %TMPDIR%\*.* /Q
%PSQL% -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
%PSQL% -c "CREATE SCHEMA tiger_staging;"
%PSQL% -c "DO language 'plpgsql' $$ BEGIN IF NOT EXISTS (SELECT * FROM information_schema.schemata WHERE schema_name = 'tiger_data' ) THEN CREATE SCHEMA tiger_data; END IF;  END $$"
for /r %z in (tl_2017_34*_tract.zip ) do %UNZIPTOOL% e %z  -o%TMPDIR%
cd %TMPDIR%
%PSQL% -c "CREATE TABLE tiger_data.NJ_tract(CONSTRAINT pk_NJ_tract PRIMARY KEY (tract_id) ) INHERITS(tiger.tract); " 
%SHP2PGSQL% -D -c -s 4269 -g the_geom   -W "latin1" tl_2017_34_tract.dbf tiger_staging.nj_tract | %PSQL%
%PSQL% -c "ALTER TABLE tiger_staging.NJ_tract RENAME geoid TO tract_id;  SELECT loader_load_staged_data(lower('NJ_tract'), lower('NJ_tract')); "
	%PSQL% -c "CREATE INDEX tiger_data_NJ_tract_the_geom_gist ON tiger_data.NJ_tract USING gist(the_geom);"
	%PSQL% -c "VACUUM ANALYZE tiger_data.NJ_tract;"
	%PSQL% -c "ALTER TABLE tiger_data.NJ_tract ADD CONSTRAINT chk_statefp CHECK (statefp = '34');"
cd \gisdata
%WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_34001_faces.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_34003_faces.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_34005_faces.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_34007_faces.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_34009_faces.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_34011_faces.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_34013_faces.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_34015_faces.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_34017_faces.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_34019_faces.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_34021_faces.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_34023_faces.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_34025_faces.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_34027_faces.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_34029_faces.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_34031_faces.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_34033_faces.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_34035_faces.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_34037_faces.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_34039_faces.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FACES/tl_2017_34041_faces.zip 
cd \gisdata/www2.census.gov/geo/tiger/TIGER2017/FACES/
del %TMPDIR%\*.* /Q
%PSQL% -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
%PSQL% -c "CREATE SCHEMA tiger_staging;"
%PSQL% -c "DO language 'plpgsql' $$ BEGIN IF NOT EXISTS (SELECT * FROM information_schema.schemata WHERE schema_name = 'tiger_data' ) THEN CREATE SCHEMA tiger_data; END IF;  END $$"
for /r %z in (tl_*_34*_faces*.zip ) do %UNZIPTOOL% e %z  -o%TMPDIR%
cd %TMPDIR%
%PSQL% -c "CREATE TABLE tiger_data.NJ_faces(CONSTRAINT pk_NJ_faces PRIMARY KEY (gid)) INHERITS(tiger.faces);" 
for /r %z in (*faces*.dbf) do (%SHP2PGSQL% -D   -D -s 4269 -g the_geom -W "latin1" %z tiger_staging.NJ_faces | %PSQL% & %PSQL% -c "SELECT loader_load_staged_data(lower('NJ_faces'), lower('NJ_faces'));")

%PSQL% -c "CREATE INDEX tiger_data_NJ_faces_the_geom_gist ON tiger_data.NJ_faces USING gist(the_geom);"
	%PSQL% -c "CREATE INDEX idx_tiger_data_NJ_faces_tfid ON tiger_data.NJ_faces USING btree (tfid);"
	%PSQL% -c "CREATE INDEX idx_tiger_data_NJ_faces_countyfp ON tiger_data.NJ_faces USING btree (countyfp);"
	%PSQL% -c "ALTER TABLE tiger_data.NJ_faces ADD CONSTRAINT chk_statefp CHECK (statefp = '34');"
	%PSQL% -c "vacuum analyze tiger_data.NJ_faces;"
cd \gisdata
%WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_34001_featnames.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_34003_featnames.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_34005_featnames.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_34007_featnames.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_34009_featnames.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_34011_featnames.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_34013_featnames.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_34015_featnames.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_34017_featnames.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_34019_featnames.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_34021_featnames.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_34023_featnames.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_34025_featnames.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_34027_featnames.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_34029_featnames.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_34031_featnames.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_34033_featnames.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_34035_featnames.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_34037_featnames.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_34039_featnames.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/tl_2017_34041_featnames.zip 
cd \gisdata/www2.census.gov/geo/tiger/TIGER2017/FEATNAMES/
del %TMPDIR%\*.* /Q
%PSQL% -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
%PSQL% -c "CREATE SCHEMA tiger_staging;"
%PSQL% -c "DO language 'plpgsql' $$ BEGIN IF NOT EXISTS (SELECT * FROM information_schema.schemata WHERE schema_name = 'tiger_data' ) THEN CREATE SCHEMA tiger_data; END IF;  END $$"
for /r %z in (tl_*_34*_featnames*.zip ) do %UNZIPTOOL% e %z  -o%TMPDIR%
cd %TMPDIR%
%PSQL% -c "CREATE TABLE tiger_data.NJ_featnames(CONSTRAINT pk_NJ_featnames PRIMARY KEY (gid)) INHERITS(tiger.featnames);ALTER TABLE tiger_data.NJ_featnames ALTER COLUMN statefp SET DEFAULT '34';" 
for /r %z in (*featnames*.dbf) do (%SHP2PGSQL% -D   -D -s 4269 -g the_geom -W "latin1" %z tiger_staging.NJ_featnames | %PSQL% & %PSQL% -c "SELECT loader_load_staged_data(lower('NJ_featnames'), lower('NJ_featnames'));")

%PSQL% -c "CREATE INDEX idx_tiger_data_NJ_featnames_snd_name ON tiger_data.NJ_featnames USING btree (soundex(name));"
%PSQL% -c "CREATE INDEX idx_tiger_data_NJ_featnames_lname ON tiger_data.NJ_featnames USING btree (lower(name));"
%PSQL% -c "CREATE INDEX idx_tiger_data_NJ_featnames_tlid_statefp ON tiger_data.NJ_featnames USING btree (tlid,statefp);"
%PSQL% -c "ALTER TABLE tiger_data.NJ_featnames ADD CONSTRAINT chk_statefp CHECK (statefp = '34');"
%PSQL% -c "vacuum analyze tiger_data.NJ_featnames;"
cd \gisdata
%WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_34001_edges.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_34003_edges.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_34005_edges.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_34007_edges.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_34009_edges.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_34011_edges.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_34013_edges.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_34015_edges.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_34017_edges.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_34019_edges.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_34021_edges.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_34023_edges.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_34025_edges.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_34027_edges.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_34029_edges.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_34031_edges.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_34033_edges.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_34035_edges.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_34037_edges.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_34039_edges.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/EDGES/tl_2017_34041_edges.zip 
cd \gisdata/www2.census.gov/geo/tiger/TIGER2017/EDGES/
del %TMPDIR%\*.* /Q
%PSQL% -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
%PSQL% -c "CREATE SCHEMA tiger_staging;"
%PSQL% -c "DO language 'plpgsql' $$ BEGIN IF NOT EXISTS (SELECT * FROM information_schema.schemata WHERE schema_name = 'tiger_data' ) THEN CREATE SCHEMA tiger_data; END IF;  END $$"
for /r %z in (tl_*_34*_edges*.zip ) do %UNZIPTOOL% e %z  -o%TMPDIR%
cd %TMPDIR%
%PSQL% -c "CREATE TABLE tiger_data.NJ_edges(CONSTRAINT pk_NJ_edges PRIMARY KEY (gid)) INHERITS(tiger.edges);"
for /r %z in (*edges*.dbf) do (%SHP2PGSQL% -D   -D -s 4269 -g the_geom -W "latin1" %z tiger_staging.NJ_edges | %PSQL% & %PSQL% -c "SELECT loader_load_staged_data(lower('NJ_edges'), lower('NJ_edges'));")

%PSQL% -c "ALTER TABLE tiger_data.NJ_edges ADD CONSTRAINT chk_statefp CHECK (statefp = '34');"
%PSQL% -c "CREATE INDEX idx_tiger_data_NJ_edges_tlid ON tiger_data.NJ_edges USING btree (tlid);"
%PSQL% -c "CREATE INDEX idx_tiger_data_NJ_edgestfidr ON tiger_data.NJ_edges USING btree (tfidr);"
%PSQL% -c "CREATE INDEX idx_tiger_data_NJ_edges_tfidl ON tiger_data.NJ_edges USING btree (tfidl);"
%PSQL% -c "CREATE INDEX idx_tiger_data_NJ_edges_countyfp ON tiger_data.NJ_edges USING btree (countyfp);"
%PSQL% -c "CREATE INDEX tiger_data_NJ_edges_the_geom_gist ON tiger_data.NJ_edges USING gist(the_geom);"
%PSQL% -c "CREATE INDEX idx_tiger_data_NJ_edges_zipl ON tiger_data.NJ_edges USING btree (zipl);"
%PSQL% -c "CREATE TABLE tiger_data.NJ_zip_state_loc(CONSTRAINT pk_NJ_zip_state_loc PRIMARY KEY(zip,stusps,place)) INHERITS(tiger.zip_state_loc);"
%PSQL% -c "INSERT INTO tiger_data.NJ_zip_state_loc(zip,stusps,statefp,place) SELECT DISTINCT e.zipl, 'NJ', '34', p.name FROM tiger_data.NJ_edges AS e INNER JOIN tiger_data.NJ_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.NJ_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
%PSQL% -c "CREATE INDEX idx_tiger_data_NJ_zip_state_loc_place ON tiger_data.NJ_zip_state_loc USING btree(soundex(place));"
%PSQL% -c "ALTER TABLE tiger_data.NJ_zip_state_loc ADD CONSTRAINT chk_statefp CHECK (statefp = '34');"
%PSQL% -c "vacuum analyze tiger_data.NJ_edges;"
%PSQL% -c "vacuum analyze tiger_data.NJ_zip_state_loc;"
%PSQL% -c "CREATE TABLE tiger_data.NJ_zip_lookup_base(CONSTRAINT pk_NJ_zip_state_loc_city PRIMARY KEY(zip,state, county, city, statefp)) INHERITS(tiger.zip_lookup_base);"
%PSQL% -c "INSERT INTO tiger_data.NJ_zip_lookup_base(zip,state,county,city, statefp) SELECT DISTINCT e.zipl, 'NJ', c.name,p.name,'34'  FROM tiger_data.NJ_edges AS e INNER JOIN tiger.county As c  ON (e.countyfp = c.countyfp AND e.statefp = c.statefp AND e.statefp = '34') INNER JOIN tiger_data.NJ_faces AS f ON (e.tfidl = f.tfid OR e.tfidr = f.tfid) INNER JOIN tiger_data.NJ_place As p ON(f.statefp = p.statefp AND f.placefp = p.placefp ) WHERE e.zipl IS NOT NULL;"
%PSQL% -c "ALTER TABLE tiger_data.NJ_zip_lookup_base ADD CONSTRAINT chk_statefp CHECK (statefp = '34');"
%PSQL% -c "CREATE INDEX idx_tiger_data_NJ_zip_lookup_base_citysnd ON tiger_data.NJ_zip_lookup_base USING btree(soundex(city));"
cd \gisdata
%WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_34001_addr.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_34003_addr.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_34005_addr.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_34007_addr.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_34009_addr.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_34011_addr.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_34013_addr.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_34015_addr.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_34017_addr.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_34019_addr.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_34021_addr.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_34023_addr.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_34025_addr.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_34027_addr.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_34029_addr.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_34031_addr.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_34033_addr.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_34035_addr.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_34037_addr.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_34039_addr.zip 
 %WGETTOOL% --mirror  https://www2.census.gov/geo/tiger/TIGER2017/ADDR/tl_2017_34041_addr.zip 
cd \gisdata/www2.census.gov/geo/tiger/TIGER2017/ADDR/
del %TMPDIR%\*.* /Q
%PSQL% -c "DROP SCHEMA IF EXISTS tiger_staging CASCADE;"
%PSQL% -c "CREATE SCHEMA tiger_staging;"
%PSQL% -c "DO language 'plpgsql' $$ BEGIN IF NOT EXISTS (SELECT * FROM information_schema.schemata WHERE schema_name = 'tiger_data' ) THEN CREATE SCHEMA tiger_data; END IF;  END $$"
for /r %z in (tl_*_34*_addr*.zip ) do %UNZIPTOOL% e %z  -o%TMPDIR%
cd %TMPDIR%
%PSQL% -c "CREATE TABLE tiger_data.NJ_addr(CONSTRAINT pk_NJ_addr PRIMARY KEY (gid)) INHERITS(tiger.addr);ALTER TABLE tiger_data.NJ_addr ALTER COLUMN statefp SET DEFAULT '34';" 
for /r %z in (*addr*.dbf) do (%SHP2PGSQL% -D   -D -s 4269 -g the_geom -W "latin1" %z tiger_staging.NJ_addr | %PSQL% & %PSQL% -c "SELECT loader_load_staged_data(lower('NJ_addr'), lower('NJ_addr'));")

%PSQL% -c "ALTER TABLE tiger_data.NJ_addr ADD CONSTRAINT chk_statefp CHECK (statefp = '34');"
	%PSQL% -c "CREATE INDEX idx_tiger_data_NJ_addr_least_address ON tiger_data.NJ_addr USING btree (least_hn(fromhn,tohn) );"
	%PSQL% -c "CREATE INDEX idx_tiger_data_NJ_addr_tlid_statefp ON tiger_data.NJ_addr USING btree (tlid, statefp);"
	%PSQL% -c "CREATE INDEX idx_tiger_data_NJ_addr_zip ON tiger_data.NJ_addr USING btree (zip);"
	%PSQL% -c "CREATE TABLE tiger_data.NJ_zip_state(CONSTRAINT pk_NJ_zip_state PRIMARY KEY(zip,stusps)) INHERITS(tiger.zip_state); "
	%PSQL% -c "INSERT INTO tiger_data.NJ_zip_state(zip,stusps,statefp) SELECT DISTINCT zip, 'NJ', '34' FROM tiger_data.NJ_addr WHERE zip is not null;"
	%PSQL% -c "ALTER TABLE tiger_data.NJ_zip_state ADD CONSTRAINT chk_statefp CHECK (statefp = '34');"
	%PSQL% -c "vacuum analyze tiger_data.NJ_addr;"
