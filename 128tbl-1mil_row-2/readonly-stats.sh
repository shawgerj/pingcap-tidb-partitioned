#/bin/bash

outfile='readonly.summary.stats'

printf 'wb\tcap\ttxns\tqueries\tlat-avg\tlat-95\n' > $outfile

for i in {1..7}
do
    wb=$((8-i))
    cap=$((i))

    infile=wb${wb}_cap${cap}_readonly.out
    awk -v w="${wb}" -v c="${cap}" '/transactions/ { tps=$2 } /queries/ { qps=$2 } /avg:/ { latavg=$2 } /95th/ { lat95=$3 } END {print w, c, tps, qps, latavg, lat95}' OFS="\t" $infile >> $outfile
done

