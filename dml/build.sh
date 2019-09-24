#!/bin/sh

# Script che costruisce il database
export DATABASE_NAME="farmhouse"

alias basedati=mysql\ $DATABASE_NAME

echo "Creo base di dati \"$DATABASE_NAME\"..."
mysql -e "DROP DATABASE IF EXISTS $DATABASE_NAME"
mysql -e "CREATE DATABASE $DATABASE_NAME CHARACTER SET utf8 COLLATE utf8_general_ci"

echo "Costruisco area servizi..."
basedati < ./area_blu.sql

echo "Costruisco area stalle  ..."
basedati < ./area_gialla.sql

echo "Costruisco area animali..."
basedati < ./area_rossa.sql

echo "Costruisco area produzione..."
basedati < ./area_verde.sql

echo "Costruzione delle chiavi esterne e dei vincoli tra le frontiere...."
basedati < ./ponti_aree.sql

echo "Aggiunta vincoli aggiuntivi..."
basedati < ./vincoli.sql

echo "Configurazione procedure ed automatismi di mantenimento delle ridodanze..."
basedati < ./ridondanze.sql
basedati < ./inspascolo.sql

echo "Terminato!"
unalias basedati
