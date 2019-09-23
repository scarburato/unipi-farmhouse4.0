#!/bin/bash

export DATABASE_NAME="farmhouse"

for (( i=0; i<4; i++ ))
do
	echo "Chiamata numero $i a popolaAnimali..."
	mysql $DATABASE_NAME -e "CALL popolaAnimali(60);" &
	
	pids[${i}]=$!
done

# wait for all pids
for pid in ${pids[*]}; do
	echo "Aspetto $pid"
	wait $pid
done

