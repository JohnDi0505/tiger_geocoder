## This script is to generate a shell script for the specified platform that loads in the county and state lookup tables.

"C:\Program Files\PostgreSQL\11\bin\psql" -U postgres -h localhost -d geocoder -A -t -c "SELECT loader_generate_nation_script('windows')" > C:\postgis\output\loader_generate_nation_script.bat