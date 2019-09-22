#!/bin/bash
export DATABASE_NAME="farmhouse"

alias basedati=mysql\ $DATABASE_NAME

export MARGINE_INF=42.741840
export MARGINE_SUP=42.756280

export MARGINE_DX=11.0249000
export MARGINE_SX=11.0009000

export ANIMALI=(1 2 3 4 5 6 7 8 9 10)

for animale in ${ANIMALI[*]}
do
	pos=$(( ( RANDOM % 750 )  + 1 ))
	echo "Genero per animale $animale. $pos posizioni fittizie saranno generate... "
	
	
		
	echo "Fatto."
done


unalias basedati
