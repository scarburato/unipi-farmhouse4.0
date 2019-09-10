#!/bin/sh

# Script che costruisce il database
export DATABASE_NAME="FarmHouse"

mysql -e "DROP DATABASE IF EXISTS $DATABASE_NAME"
mysql -e "CREATE DATABASE $DATABASE_NAME CHARACTER SET utf8 COLLATE utf8_general_ci"

mysql $DATABASE_NAME < ./dml/area_blu.sql
mysql $DATABASE_NAME < ./dml/area_gialla.sql
mysql $DATABASE_NAME < ./dml/area_rossa.sql
mysql $DATABASE_NAME < ./dml/area_verde.sql

mysql $DATABASE_NAME < ./dml/ponti_aree.sql
