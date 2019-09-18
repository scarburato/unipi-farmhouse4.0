#!/bin/bash

export DATABASE_NAME="FarmHouse"
alias basedati=mysql\ $DATABASE_NAME

for (( i=0; $[$i < 300]; i=$[$i + 1] ))
do
	basedati -c \
	"INSERT INTO Animale(razza, specie, locale, sesso, altezza) VALUES
	($razza, $specie, $locale, $sesso, $altezza)" 
done 

unalias basedati
