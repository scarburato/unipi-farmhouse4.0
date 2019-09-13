#!/bin/sh

# Script che costruisce il database
export DATABASE_NAME="FarmHouse"

echo "Creo base di dati \"$DATABASE_NAME\"..."
mysql -e "DROP DATABASE IF EXISTS $DATABASE_NAME"
mysql -e "CREATE DATABASE $DATABASE_NAME CHARACTER SET utf8 COLLATE utf8_general_ci"

echo "Costruisco area servizi..."
mysql $DATABASE_NAME < ./dml/area_blu.sql

echo "Costruisco area stalle  ..."
mysql $DATABASE_NAME < ./dml/area_gialla.sql

echo "Costruisco area animali..."
mysql $DATABASE_NAME < ./dml/area_rossa.sql

echo "Costruisco area produzione..."
mysql $DATABASE_NAME < ./dml/area_verde.sql

echo "Costruzione delle chiavi esterne e dei vincoli tra le frontiere...."
mysql $DATABASE_NAME < ./dml/ponti_aree.sql

echo "Aggiunta vincoli aggiuntivi..."


echo "Terminato!"
