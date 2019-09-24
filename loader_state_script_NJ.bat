## This script is to generate a shell script for the specified platform that loads in the NJ state lookup tables.

"C:\Program Files\PostgreSQL\11\bin\psql" -U postgres -h localhost -d geocoder -A -t -c "SELECT loader_generate_script(ARRAY['NJ'], 'windows')" > C:\postgis\output\loader_generate_script_NJ.bat