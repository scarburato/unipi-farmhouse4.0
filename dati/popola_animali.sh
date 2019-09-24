#!/bin/bash

export DATABASE_NAME="farmhouse"

mysql $DATABASE_NAME < popola2.sql
mysql $DATABASE_NAME < fake_pos.sql

for (( i=0; i<10; i++ ))
do
	echo -n "Chiamata numero $i a popolaAnimali..."
	mysql $DATABASE_NAME -e "CALL popolaAnimali(40);" &
	
	echo " in eseguzione con PID $!"
	pids[${i}]=$!
	
	sleep 0.68
done

# wait for all pids
for pid in ${pids[*]}; do
	echo -n "Aspetto $pid..."
	wait $pid
	echo " eccolo!"
done

pids=()

for (( i=0; i<10; i++ ))
do
	echo -n "Chiamata numero $i a genFakePos..."
	mysql $DATABASE_NAME -e "CALL genFakePos(40, $(( $i * 60)) );" &
	
	echo " in eseguzione con PID $!"
	pids[${i}]=$!
	
	sleep 0.68
done

# wait for all pids
for pid in ${pids[*]}; do
	echo -n "Aspetto $pid..."
	wait $pid
	echo " eccolo!"
done
